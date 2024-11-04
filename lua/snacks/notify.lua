---@class snacks.notify
---@overload fun(msg: string|string[], opts?: snacks.notify.Opts)
local M = setmetatable({}, {
  __call = function(t, ...)
    return t.notify(...)
  end,
})

---@alias snacks.notify.Opts {level?: number, title?: string, once?: boolean, lang?: string}

---@param msg string|string[]
---@param opts? snacks.notify.Opts
function M.notify(msg, opts)
  opts = opts or {}
  local notify = vim[opts.once and "notify_once" or "notify"] --[[@as fun(...)]]
  notify = vim.in_fast_event() and vim.schedule_wrap(notify) or notify
  msg = type(msg) == "table" and table.concat(msg, "\n") or msg --[[@as string]]
  msg = vim.trim(msg)
  notify(msg, opts.level, {
    title = opts.title or "Snacks",
    on_open = function(win)
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = "n"
      vim.wo[win].spell = false
      local buf = vim.api.nvim_win_get_buf(win)
      local lang = opts.lang or "markdown"
      if not pcall(vim.treesitter.start, buf, lang) then
        vim.bo[buf].filetype = lang
        vim.bo[buf].syntax = lang
      end
    end,
  })
end

---@param msg string|string[]
---@param opts? snacks.notify.Opts
function M.warn(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.WARN }, opts or {}))
end

---@param msg string|string[]
---@param opts? snacks.notify.Opts
function M.info(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.INFO }, opts or {}))
end

---@param msg string|string[]
---@param opts? snacks.notify.Opts
function M.error(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.ERROR }, opts or {}))
end

return M