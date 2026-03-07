local function extract_code_block()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- 1. Find the code block
	local start_line, end_line
	for i = cursor_line, 0, -1 do
		if lines[i + 1]:match("^```") then
			start_line = i
			break
		end
	end
	if start_line then
		for i = start_line + 1, #lines - 1 do
			if lines[i + 1]:match("^```") then
				end_line = i
				break
			end
		end
	end

	if not start_line or not end_line then
		vim.notify("No code block found under cursor.", vim.log.levels.WARN)
		return
	end

	-- 2. Extract content
	local content = {}
	for i = start_line + 1, end_line - 1 do
		table.insert(content, lines[i + 1])
	end

	-- 3. Detect filename (header)
	local header = lines[start_line + 1]
	local detected_name = header:match("^```%w+:(%S+)") or header:match("^```%S+%s+(%S+)") or ""

	-- 4. Prompt for filename
	vim.ui.input({
		prompt = "Save to (relative to ./): ",
		default = detected_name,
		completion = "file",
	}, function(input_name)
		if not input_name or input_name == "" then
			return
		end

		-- === KEY FIXES BELOW === --

		-- A. Resolve full path relative to CWD (./)
		local full_path = vim.fn.fnamemodify(input_name, ":p")

		-- B. Get the directory part of that path
		local dir_path = vim.fn.fnamemodify(full_path, ":h")

		-- C. Create the directory structure (mkdir -p)
		-- This creates 'src/i18n/en' automatically if it doesn't exist
		local ok, err = pcall(vim.fn.mkdir, dir_path, "p")
		if not ok then
			vim.notify("Could not create directory: " .. err, vim.log.levels.ERROR)
			return
		end

		-- D. Write the file
		local file = io.open(full_path, "w")
		if file then
			file:write(table.concat(content, "\n"))
			file:close()
			vim.notify("Saved: " .. input_name, vim.log.levels.INFO)

			-- E. Open in split
			vim.schedule(function()
				vim.cmd("vsplit " .. vim.fn.fnameescape(input_name))
			end)
		else
			vim.notify("Failed to write file.", vim.log.levels.ERROR)
		end
	end)
end

-- Map it
vim.keymap.set("v", "<leader>py", extract_code_block, { desc = "Parrot: Extract code block" })

local _anthropic = {
	name = "anthropic",
	endpoint = "https://api.anthropic.com/v1/messages",
	model_endpoint = "https://api.anthropic.com/v1/models",
	api_key = os.getenv("ANTHROPIC_API_KEY"),
	params = {
		chat = { max_tokens = 4096 },
		command = { max_tokens = 4096 },
	},
	topic = {
		model = "claude-3-5-haiku-latest",
		params = { max_tokens = 32 },
	},
	headers = function(self)
		return {
			["Content-Type"] = "application/json",
			["x-api-key"] = self.api_key,
			["anthropic-version"] = "2023-06-01",
		}
	end,
	-- Using model aliases (https://docs.anthropic.com/en/docs/about-claude/models/overview#model-aliases)
	models = {
		"claude-opus-4-5",
		"claude-opus-4-1",
		"claude-sonnet-4-5",
		"claude-haiku-4-5",
	},
	preprocess_payload = function(payload)
		for _, message in ipairs(payload.messages) do
			message.content = message.content:gsub("^%s*(.-)%s*$", "%1")
		end
		if payload.messages[1] and payload.messages[1].role == "system" then
			-- remove the first message that serves as the system prompt as anthropic
			-- expects the system prompt to be part of the API call body and not the messages
			payload.system = payload.messages[1].content
			table.remove(payload.messages, 1)
		end
		return payload
	end,
}

return {
	"frankroeder/parrot.nvim",
	dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
	event = "VeryLazy",
	lazy = false,
	cond = os.getenv("GEMINI_API_KEY") ~= nil and os.getenv("ANTHROPIC_API_KEY") ~= nil,
	-- optionally include "folke/noice.nvim" or "rcarriga/nvim-notify" for beautiful notifications
	config = function()
		require("parrot").setup({
			-- Providers must be explicitly set up to make them available.
			providers = {
				anthropic = _anthropic,
				gemini = {
					name = "gemini",
					endpoint = function(self)
						return "https://generativelanguage.googleapis.com/v1beta/models/"
							.. self._model
							.. ":streamGenerateContent?alt=sse"
					end,
					-- model_endpoint = function(self)
					-- 	return { "https://generativelanguage.googleapis.com/v1beta/models?key=" .. self.api_key }
					-- end,
					api_key = os.getenv("GEMINI_API_KEY"),
					params = {
						chat = { temperature = 1.1, topP = 1, topK = 10, maxOutputTokens = 8192 },
						command = { temperature = 0.8, topP = 1, topK = 10, maxOutputTokens = 8192 },
					},
					topic = {
						model = "gemini-1.5-flash",
						params = { maxOutputTokens = 64 },
					},
					headers = function(self)
						return {
							["Content-Type"] = "application/json",
							["x-goog-api-key"] = self.api_key,
						}
					end,
					models = {
						"gemini-3-pro-preview",
						"gemini-2.5-pro",
						"gemini-2.5-flash",
						"gemini-2.5-flash-lite",
					},
					preprocess_payload = function(payload)
						local contents = {}
						local system_instruction = nil
						for _, message in ipairs(payload.messages) do
							if message.role == "system" then
								system_instruction = { parts = { { text = message.content } } }
							else
								local role = message.role == "assistant" and "model" or "user"
								table.insert(
									contents,
									{ role = role, parts = { { text = message.content:gsub("^%s*(.-)%s*$", "%1") } } }
								)
							end
						end
						local gemini_payload = {
							contents = contents,
							generationConfig = {
								temperature = payload.temperature,
								topP = payload.topP or payload.top_p,
								maxOutputTokens = payload.max_tokens or payload.maxOutputTokens,
							},
						}
						if system_instruction then
							gemini_payload.systemInstruction = system_instruction
						end
						return gemini_payload
					end,
					process_stdout = function(response)
						if not response or response == "" then
							return nil
						end
						local success, decoded = pcall(vim.json.decode, response)
						if
							success
							and decoded.candidates
							and decoded.candidates[1]
							and decoded.candidates[1].content
							and decoded.candidates[1].content.parts
							and decoded.candidates[1].content.parts[1]
						then
							return decoded.candidates[1].content.parts[1].text
						end
						return nil
					end,
				},
			},
			-- preprocess_payload = function(payload)
			-- 	local contents = {}
			-- 	local system_instruction = nil
			-- 	for _, message in ipairs(payload.messages) do
			-- 		if message.role == "system" then
			-- 			system_instruction = { parts = { { text = message.content } } }
			-- 		else
			-- 			local role = message.role == "assistant" and "model" or "user"
			-- 			table.insert(
			-- 				contents,
			-- 				{ role = role, parts = { { text = message.content:gsub("^%s*(.-)%s*$", "%1") } } }
			-- 			)
			-- 		end
			-- 	end
			-- 	local gemini_payload = {
			-- 		contents = contents,
			-- 		generationConfig = {
			-- 			temperature = payload.temperature,
			-- 			topP = payload.topP or payload.top_p,
			-- 			maxOutputTokens = payload.max_tokens or payload.maxOutputTokens,
			-- 		},
			-- 	}
			-- 	if system_instruction then
			-- 		gemini_payload.systemInstruction = system_instruction
			-- 	end
			-- 	return gemini_payload
			-- end,
			-- process_stdout = function(response)
			-- 	if not response or response == "" then
			-- 		return nil
			-- 	end
			-- 	local success, decoded = pcall(vim.json.decode, response)
			-- 	if
			-- 		success
			-- 		and decoded.candidates
			-- 		and decoded.candidates[1]
			-- 		and decoded.candidates[1].content
			-- 		and decoded.candidates[1].content.parts
			-- 		and decoded.candidates[1].content.parts[1]
			-- 	then
			-- 		return decoded.candidates[1].content.parts[1].text
			-- 	end
			-- 	return nil
			-- end,
			cmd_prefix = "Prt",
			chat_conceal_model_params = false,
			user_input_ui = "buffer",
			toggle_target = "",
			online_model_selection = true,
			command_auto_select_response = true,
			show_context_hints = true,
			model_cache_expiry_hours = 0,
			prompts = {
				["git commit message"] = [[Given the following git diff, I want you to compose a short git commit message ]]
					.. vim.fn.system("git diff --no-color --no-ext-diff --staged"),
				Implement = [[
      You are a raw code generator.
      1. Your task is to rewrite the SELECTION based on the User's input.
      2. You have the full FILE CONTENT for context, but you must ONLY output the new version of the SELECTION.
      3. DO NOT output markdown backticks (```).
      4. DO NOT provide explanations, intro text, or outro text.
      5. Preserve indentation relative to the surrounding code.
      6. CRITICAL: You must output the **ENTIRE** code block, INCLUDING the original function signature/declaration if present.

      Context (Full File):
      {{filecontent}}

      Selection to Rewrite:
      {{selection}}

      User Input:
      ]],
			},
			hooks = {
				Complete = function(prt, params)
					local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted."
        ]]
					local model_obj = prt.get_model("command")
					prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
				end,
				CompleteFullContext = function(prt, params)
					local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{filecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted.
        ]]
					local model_obj = prt.get_model("command")
					prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
				end,
				CompleteMultiContext = function(prt, params)
					local template = [[
        I have the following code from {{filename}} and other realted files:

        ```{{filetype}}
        {{multifilecontent}}
        ```

        Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted.
        ]]
					local model_obj = prt.get_model("command")
					prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
				end,
				Explain = function(prt, params)
					local template = [[
        Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
        Break down the code's functionality, purpose, and key components.
        The goal is to help the reader understand what the code does and how it works.

        ```{{filetype}}
        {{selection}}
        ```

        Use the markdown format with codeblocks and inline code.
        Explanation of the code above:
        ]]
					local model = prt.get_model("command")
					prt.logger.info("Explaining selection with model: " .. model.name)
					prt.Prompt(params, prt.ui.Target.new, model, nil, template)
				end,
				FixBugs = function(prt, params)
					local template = [[
        You are an expert in {{filetype}}.
        Fix bugs in the below code from {{filename}} carefully and logically:
        Your task is to analyze the provided {{filetype}} code snippet, identify
        any bugs or errors present, and provide a corrected version of the code
        that resolves these issues. Explain the problems you found in the
        original code and how your fixes address them. The corrected code should
        be functional, efficient, and adhere to best practices in
        {{filetype}} programming.

        ```{{filetype}}
        {{selection}}
        ```

        Fixed code:
        ]]
					local model_obj = prt.get_model("command")
					prt.logger.info("Fixing bugs in selection with model: " .. model_obj.name)
					prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
				end,
				Optimize = function(prt, params)
					local template = [[
        You are an expert in {{filetype}}.
        Your task is to analyze the provided {{filetype}} code snippet and
        suggest improvements to optimize its performance. Identify areas
        where the code can be made more efficient, faster, or less
        resource-intensive. Provide specific suggestions for optimization,
        along with explanations of how these changes can enhance the code's
        performance. The optimized code should maintain the same functionality
        as the original code while demonstrating improved efficiency.

        ```{{filetype}}
        {{selection}}
        ```

        Optimized code:
        ]]
					local model_obj = prt.get_model("command")
					prt.logger.info("Optimizing selection with model: " .. model_obj.name)
					prt.Prompt(params, prt.ui.Target.new, model_obj, nil, template)
				end,
				UnitTests = function(prt, params)
					local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please respond by writing table driven unit tests for the code above.
        ]]
					local model_obj = prt.get_model("command")
					prt.logger.info("Creating unit tests for selection with model: " .. model_obj.name)
					prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
				end,
				Debug = function(prt, params)
					local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{selection}}
        ```
        ]]
					local model_obj = prt.get_model("command")
					prt.logger.info("Debugging selection with model: " .. model_obj.name)
					prt.Prompt(params, prt.ui.Target.enew, model_obj, nil, template)
				end,
				CommitMsg = function(prt, params)
					local futils = require("parrot.file_utils")
					if futils.find_git_root() == "" then
						prt.logger.warning("Not in a git repository")
						return
					else
						local template = [[
          I want you to act as a commit message generator. I will provide you
          with information about the task and the prefix for the task code, and
          I would like you to generate an appropriate commit message using the
          conventional commit format. Do not write any explanations or other
          words, just reply with the commit message.
          Start with a short headline as summary but then list the individual
          changes in more detail.

          Here are the changes that should be considered by this message:
          ]] .. vim.fn.system("git diff --no-color --no-ext-diff --staged")
						local model_obj = prt.get_model("command")
						prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
					end
				end,
				SpellCheck = function(prt, params)
					local chat_prompt = [[
        Your task is to take the text provided and rewrite it into a clear,
        grammatically correct version while preserving the original meaning
        as closely as possible. Correct any spelling mistakes, punctuation
        errors, verb tense issues, word choice problems, and other
        grammatical mistakes.
        ]]
					prt.ChatNew(params, chat_prompt)
				end,
				CodeConsultant = function(prt, params)
					local chat_prompt = [[
          Your task is to analyze the provided {{filetype}} code and suggest
          improvements to optimize its performance. Identify areas where the
          code can be made more efficient, faster, or less resource-intensive.
          Provide specific suggestions for optimization, along with explanations
          of how these changes can enhance the code's performance. The optimized
          code should maintain the same functionality as the original code while
          demonstrating improved efficiency.

          Here is the code
          ```{{filetype}}
          {{filecontent}}
          ```
        ]]
					prt.ChatNew(params, chat_prompt)
				end,
				ProofReader = function(prt, params)
					local chat_prompt = [[
        I want you to act as a proofreader. I will provide you with texts and
        I would like you to review them for any spelling, grammar, or
        punctuation errors. Once you have finished reviewing the text,
        provide me with any necessary corrections or suggestions to improve the
        text. Highlight the corrected fragments (if any) using markdown backticks.

        When you have done that subsequently provide me with a slightly better
        version of the text, but keep close to the original text.

        Finally provide me with an ideal version of the text.

        Whenever I provide you with text, you reply in this format directly:

        ## Corrected text:

        {corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there are no corrections made}

        ## Slightly better text

        {slightly better text}

        ## Ideal text

        {ideal text}
        ]]
					prt.ChatNew(params, chat_prompt)
				end,
				Chatter = function(prt, params)
					local chat_prompt = [[
        You are an expert in {{filetype}}.
        Your task is to analyze the provided {{filetype}} code snippet and
        exectue a request provided below the code. Provide only the solution, you are allowed
				to explain only if the logic is complex or implicit.

        ```{{filetype}}
        {{selection}}
        ```
        ]]
					prt.ChatNew(params, chat_prompt)
				end,
			},
		})
		vim.keymap.set("n", "<leader>py", function()
			-- 1. Get the path of the current buffer relative to the project root
			-- use "%:p" if you prefer absolute paths
			local filepath = vim.fn.expand("%:.")

			-- 2. Check if the buffer has a name
			if filepath == "" then
				vim.notify("No file name found for current buffer", vim.log.levels.WARN)
				return
			end

			-- 3. Construct the parrot marker tag
			local tag = " @file:" .. filepath .. " "

			-- 4. Toggle/Open the Chat window
			-- Change "PrtChatToggle" to "PrtChatNew" if you always want a new chat
			vim.cmd("PrtChatToggle")

			-- 5. Insert the text at the cursor position
			-- We use schedule to ensure the chat window is focused before pasting
			vim.schedule(function()
				-- Ensure we are in insert mode at the end of the prompt
				vim.cmd("startinsert")
				-- Insert the text
				vim.api.nvim_put({ tag }, "c", true, true)
			end)
		end, { desc = "Parrot: Add current file to chat context" })
	end,
	keys = {
		{ "<leader>pc", "<cmd>PrtChatNew<cr>", mode = { "n" }, desc = "New Chat" },
		{ "<leader>pp", ":<C-u>'<,'>PrtChatPaste<cr>", mode = { "v" }, desc = "Past selection to most recent chat" },
		{ "<leader>pg", "<cmd>PrtChatRespond<cr>", mode = { "n" }, desc = "Chat respond" },
		{ "<leader>pc", ":<C-u>'<,'>PrtChatter<cr>", mode = { "v" }, desc = "Visual Chat New" },
		{ "<leader>pt", "<cmd>PrtChatToggle<cr>", mode = { "n" }, desc = "Toggle Popup Chat" },
		{ "<leader>pf", "<cmd>PrtChatFinder<cr>", mode = { "n" }, desc = "Chat Finder" },
		{ "<leader>pd", "<cmd>PrtChatDelete<cr>", mode = { "n" }, desc = "Chat delete" },
		{ "<leader>pr", "<cmd>PrtRewrite<cr>", mode = { "n" }, desc = "Inline Rewrite" },
		{ "<leader>pr", ":<C-u>'<,'>PrtRewrite<cr>", mode = { "v" }, desc = "Visual Rewrite" },
		-- {
		-- 	"<leader>pa",
		-- 	"<cmd>PrtRetry<cr>",
		-- 	mode = { "n" },
		-- 	desc = "Retry rewrite/append/prepend command",
		-- },
		-- { "<C-g>a", "<cmd>PrtAppend<cr>", mode = { "n", "i" }, desc = "Append" },
		{ "<leader>a", ":<C-u>'<,'>PrtAppend<cr>", mode = { "v" }, desc = "Visual Append" },
		-- { "<C-g>o", "<cmd>PrtPrepend<cr>", mode = { "n", "i" }, desc = "Prepend" },
		{ "<leader>o", ":<C-u>'<,'>PrtPrepend<cr>", mode = { "v" }, desc = "Visual Prepend" },
		{ "<C-g>e", ":<C-u>'<,'>PrtEnew<cr>", mode = { "v" }, desc = "Visual Enew" },
		{ "<leader>pb", ":<C-u>'<,'>PrtFixBugs<cr>", mode = { "v" }, desc = "Visual Fix Bugs" },
		{ "<leader>ps", "<cmd>PrtStop<cr>", mode = { "n", "v", "x" }, desc = "Stop" },
		{
			"<leader>pe",
			":<C-u>'<,'>PrtComplete<cr>",
			mode = { "n", "v", "x" },
			desc = "Complete visual selection",
		},
		{
			"<leader>pi",
			":<C-u>'<,'>PrtImplement<cr>",
			mode = { "n" },
			desc = "Implement a comment",
		},
		{
			"<leader>pi",
			":<C-u>'<,'>PrtRewrite Implement<cr>",
			mode = { "v" },
			desc = "Implement a selection",
		},
		{ "<leader>px", "<cmd>PrtContext<cr>", mode = { "n" }, desc = "Open context file" },
		{ "<leader>pm", "<cmd>PrtModel<cr>", mode = { "n" }, desc = "Select model" },
		{ "<leader>p;", "<cmd>PrtProvider<cr>", mode = { "n" }, desc = "Select provider" },
		{ "<leader>pq", "<cmd>PrtAsk<cr>", mode = { "n" }, desc = "Ask a question" },
		{ "<leader>pnn", ":<C-u>'<,'>PrtSpellCheck<cr>", mode = { "v" }, desc = "Spell check" },
		{ "<leader>pnm", ":<C-u>'<,'>PrtProofReader<cr>", mode = { "v" }, desc = "Proof reader" },
		{ "<leader>ph", "<cmd>PrtCommitMsg<cr>", mode = { "n" }, desc = "Commit message based on diff" },
	},
}
