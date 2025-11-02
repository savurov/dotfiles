return {
  {
    'kdheepak/lazygit.nvim',
    cmd = { 'LazyGit', 'LazyGitConfig', 'LazyGitCurrentFile', 'LazyGitFilter', 'LazyGitFilterCurrentFile' },
    keys = { { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit (float)' } },
    dependencies = { 'nvim-lua/plenary.nvim' },
    init = function()
      -- максимально крупное окно (почти «во весь экран»)
      vim.g.lazygit_floating_window_scaling_factor = 1.0
      vim.g.lazygit_floating_window_winblend = 0 -- без прозрачности
      -- чтобы LazyGit открывал файлы/коммиты в текущем экземпляре Neovim
      vim.g.lazygit_use_neovim_remote = 1
      -- если используешь nvr:
      -- vim.env.GIT_EDITOR = [[nvr -cc split --remote-wait +'set bufhidden=wipe']]
    end,
  },
}
