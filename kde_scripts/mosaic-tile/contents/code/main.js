var GAP = 12;
var OVERLAP = 28;
var windowOrderByOutput = {};

function isUsableWindow(window) {
  return (
    window &&
    window.normalWindow &&
    !window.minimized &&
    !window.skipTaskbar &&
    !window.fullScreen
  );
}

function sameOutput(window, output) {
  return window.output && output && window.output === output;
}

function outputKey(output) {
  return output && output.name ? output.name : "";
}

function windowKey(window) {
  return window && window.internalId ? String(window.internalId) : "";
}

function stableOrderWindows(output, windows) {
  var key = outputKey(output);
  var previous = windowOrderByOutput[key] || [];
  var previousIndex = {};
  var ordered = [];
  var seen = {};

  for (var i = 0; i < previous.length; ++i) {
    previousIndex[previous[i]] = i;
  }

  windows.sort(function (a, b) {
    var aKey = windowKey(a);
    var bKey = windowKey(b);
    var aKnown = previousIndex.hasOwnProperty(aKey);
    var bKnown = previousIndex.hasOwnProperty(bKey);

    if (aKnown && bKnown) {
      return previousIndex[aKey] - previousIndex[bKey];
    }
    if (aKnown) {
      return -1;
    }
    if (bKnown) {
      return 1;
    }
    return 0;
  });

  for (var j = 0; j < windows.length; ++j) {
    var w = windows[j];
    var wKey = windowKey(w);
    ordered.push(wKey);
    seen[wKey] = true;
  }

  windowOrderByOutput[key] = ordered;
  return windows;
}

function activeOutput() {
  if (workspace.activeWindow && workspace.activeWindow.output) {
    return workspace.activeWindow.output;
  }

  return workspace.activeScreen;
}

function areaFor(output) {
  if (isPrimaryOutput(output) && workspace.activeWindow && sameOutput(workspace.activeWindow, output)) {
    return workspace.clientArea(KWin.MaximizeArea, workspace.activeWindow);
  }

  return output.geometry;
}

function windowsOnOutput(output) {
  var windows = workspace.stackingOrder;
  var result = [];

  for (var i = 0; i < windows.length; ++i) {
    var window = windows[i];

    if (isUsableWindow(window) && window.output === output) {
      result.push(window);
    }
  }

  return stableOrderWindows(output, result);
}

function setGeometry(window, output, x, y, width, height) {
  window.setMaximize(false, false);

  if (window.tile) {
    window.tile = null;
  }

  var q = Object.assign({}, window.frameGeometry);

  q.x = Math.round(x);
  q.y = Math.round(y);
  q.width = Math.max(50, Math.round(width));
  q.height = Math.max(50, Math.round(height));

  window.frameGeometry = q;
}
function tileVertical(output, windows) {
  var area = areaFor(output);
  var count = windows.length;
  if (count === 0) {
    return;
  }

  var height = (area.height - GAP * (count + 1)) / count;
  var width = area.width - GAP * 2;

  for (var i = 0; i < count; ++i) {
    setGeometry(
      windows[i],
      output,
      area.x + GAP,
      area.y + GAP + i * (height + GAP),
      width,
      height,
    );
  }

  raiseWindows(windows);
}

function tileMosaic(output, windows) {
  var area = areaFor(output);
  var count = windows.length;
  if (count === 0) {
    return;
  }

  if (count === 1) {
    setGeometry(
      windows[0],
      output,
      area.x + GAP,
      area.y + GAP,
      area.width - GAP * 2,
      area.height - GAP * 2,
    );
    raiseWindows(windows);
    return;
  }

  var cellWidth = count === 2 ? area.width * 0.6 : area.width * 0.5;
  var cellHeight = count === 2 ? area.height * 0.75 : area.height * 0.6;
  var startX = area.x + GAP;
  var endX = area.x + area.width - cellWidth - GAP;
  var topY = area.y + GAP;
  var bottomY = area.y + area.height - cellHeight - GAP;
  var xStep = count > 1 ? (endX - startX) / (count - 1) : 0;

  for (var i = 0; i < count; ++i) {
    var x = startX + i * xStep;
    var y = i % 2 === 0 ? topY : bottomY;

    setGeometry(
      windows[i],
      output,
      x,
      y,
      cellWidth,
      cellHeight,
    );
  }

  raiseWindows(windows);
}

function outputOrderList() {
  if (typeof workspace.outputOrder === "function") {
    return workspace.outputOrder();
  }
  if (workspace.outputOrder) {
    return workspace.outputOrder;
  }
  if (typeof workspace.outputs === "function") {
    return workspace.outputs();
  }
  if (workspace.outputs) {
    return workspace.outputs;
  }
  return [];
}

function isPrimaryOutput(output) {
  var outputs = outputOrderList();
  if (outputs && outputs.length > 0) {
    return outputs[0] === output;
  }

  var geometry = output.geometry;
  return geometry.width >= geometry.height;
}

function useVerticalLayout(output) {
  if (!output) {
    return false;
  }
  return !isPrimaryOutput(output);
}

function layoutActiveScreen() {
  var output = activeOutput();
  if (!output) {
    return;
  }

  var windows = windowsOnOutput(output);

  if (useVerticalLayout(output)) {
    tileVertical(output, windows);
  } else {
    tileMosaic(output, windows);
  }
}

registerShortcut(
  "Mosaic Tile Active Screen",
  "Mosaic Tile Active Screen",
  "Meta+T",
  layoutActiveScreen,
);
