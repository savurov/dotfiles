function windowLabel(window) {
    return "\"" + (window.caption || "<no caption>") + "\"";
}

var lastActiveWindowByOutput = {};

function abs(value) {
    return Math.abs(value);
}

function windowGeometry(window) {
    return window.frameGeometry || {
        x: window.x,
        y: window.y,
        width: window.width,
        height: window.height
    };
}

function windowCenter(window) {
    var geo = windowGeometry(window);
    return {
        x: geo.x + geo.width / 2,
        y: geo.y + geo.height / 2
    };
}

function isCandidate(window, current) {
    if (window === current) {
        return false;
    }
    if (!window.normalWindow || window.minimized) {
        return false;
    }
    return true;
}

function overlapSize(startA, endA, startB, endB) {
    return Math.max(0, Math.min(endA, endB) - Math.max(startA, startB));
}

function horizontalOverlapRatio(a, b) {
    var aGeo = windowGeometry(a);
    var bGeo = windowGeometry(b);
    var overlap = overlapSize(aGeo.x, aGeo.x + aGeo.width, bGeo.x, bGeo.x + bGeo.width);
    var base = Math.min(aGeo.width, bGeo.width);
    if (base <= 0) {
        return 0;
    }
    return overlap / base;
}

function verticalOverlapRatio(a, b) {
    var aGeo = windowGeometry(a);
    var bGeo = windowGeometry(b);
    var overlap = overlapSize(aGeo.y, aGeo.y + aGeo.height, bGeo.y, bGeo.y + bGeo.height);
    var base = Math.min(aGeo.height, bGeo.height);
    if (base <= 0) {
        return 0;
    }
    return overlap / base;
}

function sameOutput(a, b) {
    return a.output && b.output && a.output === b.output;
}

function outputKey(output) {
    if (!output) {
        return "";
    }
    return output.name || "";
}

function rememberActiveWindow(window) {
    if (!window || !window.output) {
        return;
    }
    if (!window.normalWindow || window.minimized) {
        return;
    }
    lastActiveWindowByOutput[outputKey(window.output)] = window;
}

function isUsableRememberedWindow(window, current, direction, output) {
    if (!window || !output) {
        return false;
    }
    if (!isCandidate(window, current)) {
        return false;
    }
    if (!window.output || outputKey(window.output) !== outputKey(output)) {
        return false;
    }

    var currentCenter = windowCenter(current);
    var targetCenter = windowCenter(window);
    var dx = targetCenter.x - currentCenter.x;

    if (direction === "left" && dx >= 0) {
        return false;
    }
    if (direction === "right" && dx <= 0) {
        return false;
    }

    return true;
}

function allCandidates(current) {
    var windows = workspace.windowList();
    var result = [];

    for (var i = 0; i < windows.length; ++i) {
        if (isCandidate(windows[i], current)) {
            result.push(windows[i]);
        }
    }

    return result;
}

function sameOutputCandidates(current) {
    var windows = allCandidates(current);
    var result = [];

    for (var i = 0; i < windows.length; ++i) {
        if (sameOutput(windows[i], current)) {
            result.push(windows[i]);
        }
    }

    return result;
}

function pickVertical(current, direction) {
    var currentCenter = windowCenter(current);
    var candidates = sameOutputCandidates(current);
    var best = null;
    var bestScore = Infinity;

    for (var i = 0; i < candidates.length; ++i) {
        var w = candidates[i];
        var targetCenter = windowCenter(w);
        var dx = targetCenter.x - currentCenter.x;
        var dy = targetCenter.y - currentCenter.y;

        if (direction === "up" && dy >= 0) {
            continue;
        }
        if (direction === "down" && dy <= 0) {
            continue;
        }

        var score = abs(dy) * 1000 + abs(dx) * 20;

        print("[focus-direction-nav] vertical candidate=" + windowLabel(w)
            + " dx=" + dx
            + " dy=" + dy
            + " score=" + score);

        if (score < bestScore) {
            bestScore = score;
            best = w;
        }
    }

    return best;
}

function pickHorizontal(current, direction) {
    var currentCenter = windowCenter(current);
    var currentGeo = windowGeometry(current);
    var candidates = allCandidates(current);
    var remoteBest = null;
    var remoteBestScore = Infinity;
    var remoteBestRawScore = Infinity;
    var localBest = null;
    var localBestScore = Infinity;
    var localBestRawScore = Infinity;
    var monitorSwitchPenalty = Math.max(currentGeo.width * 0.35, 180) * 1000;

    for (var i = 0; i < candidates.length; ++i) {
        var w = candidates[i];
        var targetCenter = windowCenter(w);
        var dx = targetCenter.x - currentCenter.x;
        var dy = targetCenter.y - currentCenter.y;
        var yOverlap = verticalOverlapRatio(current, w);
        var horizontalDistance = abs(dx);
        var verticalDistance = abs(dy);
        var same = sameOutput(w, current);

        if (direction === "left" && dx >= 0) {
            continue;
        }
        if (direction === "right" && dx <= 0) {
            continue;
        }

        if (!same) {
            var remoteRawScore = horizontalDistance * 1000 + verticalDistance * 20 - yOverlap * 100;
            var remoteScore = remoteRawScore + monitorSwitchPenalty;

            print("[focus-direction-nav] remote candidate=" + windowLabel(w)
                + " dx=" + dx
                + " dy=" + dy
                + " overlap=" + yOverlap
                + " rawScore=" + remoteRawScore
                + " score=" + remoteScore);

            if (remoteScore < remoteBestScore) {
                remoteBestScore = remoteScore;
                remoteBestRawScore = remoteRawScore;
                remoteBest = w;
            }
            continue;
        }

        var threshold = Math.max(currentGeo.width * 0.5, 160);
        if (horizontalDistance < threshold) {
            continue;
        }

        var localRawScore = horizontalDistance * 1000 + verticalDistance * 20 - yOverlap * 100;
        var localScore = localRawScore;

        print("[focus-direction-nav] local candidate=" + windowLabel(w)
            + " dx=" + dx
            + " dy=" + dy
            + " overlap=" + yOverlap
            + " rawScore=" + localRawScore
            + " score=" + localScore);

        if (localScore < localBestScore) {
            localBestScore = localScore;
            localBestRawScore = localRawScore;
            localBest = w;
        }
    }

    print("[focus-direction-nav] horizontal summary"
        + " localRaw=" + localBestRawScore
        + " localScore=" + localBestScore
        + " remoteRaw=" + remoteBestRawScore
        + " remoteScore=" + remoteBestScore
        + " monitorPenalty=" + monitorSwitchPenalty);

    if (localBest && remoteBest) {
        if (localBestScore <= remoteBestScore) {
            return localBest;
        }
        return remoteBest;
    }

    if (localBest) {
        return localBest;
    }

    if (remoteBest) {
        var remembered = lastActiveWindowByOutput[outputKey(remoteBest.output)];
        if (isUsableRememberedWindow(remembered, current, direction, remoteBest.output)) {
            print("[focus-direction-nav] using remembered remote window=" + windowLabel(remembered));
            return remembered;
        }
        return remoteBest;
    }

    return localBest;
}

function focusDirection(direction) {
    var current = workspace.activeWindow;
    if (!current) {
        print("[focus-direction-nav] no active window");
        return;
    }

    var best = null;

    print("[focus-direction-nav] direction=" + direction + " current=" + windowLabel(current));

    if (direction === "up" || direction === "down") {
        best = pickVertical(current, direction);
    } else {
        best = pickHorizontal(current, direction);
    }

    if (!best) {
        print("[focus-direction-nav] no match for direction=" + direction);
        return;
    }

    print("[focus-direction-nav] activating " + windowLabel(best));
    workspace.activeWindow = best;
}

registerShortcut("Focus Window Left", "Focus Window Left", "Meta+H", function () {
    focusDirection("left");
});
registerShortcut("Focus Window Down", "Focus Window Down", "Meta+J", function () {
    focusDirection("down");
});
registerShortcut("Focus Window Up", "Focus Window Up", "Meta+K", function () {
    focusDirection("up");
});
registerShortcut("Focus Window Right", "Focus Window Right", "Meta+L", function () {
    focusDirection("right");
});

workspace.windowActivated.connect(function (window) {
    rememberActiveWindow(window);
});

rememberActiveWindow(workspace.activeWindow);

print("[focus-direction-nav] script loaded");
