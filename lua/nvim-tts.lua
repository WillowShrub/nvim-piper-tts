local piper_tts_buffer

vim.g.nvim_tts = {}

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local cfg = function ()
    return {
        relative = 'editor',
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        row = math.floor((vim.o.lines * 0.2) / 2),
        col = math.floor(vim.o.columns * 0.1),
        style = 'minimal',
        border = 'single',
    }
end

piper_tts_buffer.create_or_toggle = function ()
    local current = vim.api.nvim_get_current_buf()
    if vim.g.nvim_tts.id then
        if vim.g.nvim_tts.id == current then
            vim.api.nvim_win_close(0, true)
        else
            vim.api.nvim_open_win(vim.g.nvim_tts.id, true, cfg())
        end
    else
        local nvim_tts = vim.g.nvim_tts
        nvim_tts.id = vim.api.nvim_create_buf(false, true)
        vim.g.nvim_tts = nvim_tts
        vim.api.nvim_open_win(vim.g.nvim_tts.id, true, cfg())
        -- local tts_group = vim.api.nvim_create_augroup('WillowShrub.nvim_tts', {
        -- })
        vim.api.nvim_create_autocmd('BufLeave', {
            -- group = tts_group,
            buffer = nvim_tts.id,
            callback = function ()
                local sentence = vim.api.nvim_buf_get_lines(vim.g.nvim_tts.id, -2, -1, false)[1]
                if sentence == '' then
                    return
                end
                local command = ':call jobstart("echo \\"' .. string.gsub(sentence, '\"', '\\"') .. vim.g.nvim_tts.command .. "\", {'detach':1})"
                
                --print(command)
                --piper-tts -m "$HOME/.local/voice/mv2.onnx" -f - -s 11 | aplay
                --command += 
                vim.cmd(command)
            end
        })
    end
end


piper_tts_buffer.setup = function (config)
        local nvim_tts = vim.g.nvim_tts

        nvim_tts.command = '\\"| piper-tts -m \\"' ..  config.path .. '\\" -f - '
        if config.voice_number then
            nvim_tts.command = nvim_tts.command .. '-s ' .. config.voice_number
        end
        if config.command then
            nvim_tts.command = nvim_tts.command .. ' | ' .. config.command
        else
            nvim_tts.command = nvim_tts.command .. ' | ' .. 'mpv -'
        end

        vim.g.nvim_tts = nvim_tts
end

--[[vim.api.nvim_buff_attach(buffer, send_buffer?,
{
    --on_lines = function(lines?)
    on_lines = function()
        -- Read latest (second latest? One above cursorline?) line and send to piper with appropriate
        -- voice, and other options
        print("Recived line")
    end,
}) ]]--

return piper_tts_buffer
