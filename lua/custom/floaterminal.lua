local M = {}

local state = {
  buf = nil,
  win = nil,
  job_id = nil,
}

local function create_floating_window(opts)
  opts = opts or {}

  local ui = vim.api.nvim_list_uis()[1]
  local width = opts.width or math.floor(ui.width * 0.8)
  local height = opts.height or math.floor(ui.height * 0.8)

  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then state.buf = vim.api.nvim_create_buf(false, true) end

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = opts.border or 'rounded',
  })
end

function M.toggle(opts)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win)
    state.win = nil
    return
  end

  create_floating_window(opts)

  if vim.bo[state.buf].buftype ~= 'terminal' then
    vim.cmd.term()
    state.job_id = vim.bo.channel
  end

  vim.cmd.startinsert()
end

function M.send(cmd, opts)
  opts = opts or {}

  -- Ensure terminal exists
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    M.toggle(opts)
  elseif not state.win or not vim.api.nvim_win_is_valid(state.win) then
    M.toggle(opts)
  end

  if not state.job_id then state.job_id = vim.bo[state.buf].channel end

  vim.fn.chansend(state.job_id, cmd .. '\r\n')
  vim.cmd.startinsert()
end

return M
