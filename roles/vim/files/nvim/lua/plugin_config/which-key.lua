local which_key = require("which-key")

local conf = {
	window = {
		border = "single", -- none, single, double, shadow
		position = "bottom",
	},
}

local opts = {
	mode = "n", -- Normal mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = false, -- use `nowait` when creating keymaps
}

local mappings = {
	-- ["w"] = { "<cmd>update!<CR>", "Save" },
	["q"] = { "<cmd>qa<CR>", "Quit" },
	b = {
		name = "Buffer",
		c = { "<Cmd>bd!<Cr>", "Close current buffer" },
		D = { "<Cmd>%bd|e#|bd#<Cr>", "Delete all buffers" },
	},
	f = {
		-- these were sent to the telescope config file
		name = "Find (Telescope)",
		-- f = { "<Cmd>Telescope find_files<Cr>", "Telescope find [f]iles" },
		-- g = { "<Cmd>Telescope live_grep<Cr>", "Telescope [g]rep files" },
	},
	g = { name = "Git", },
	l = {
		-- check the lsp config fileOpenSIPS is a powerful but flexible multi-purpose signaling SIP Server that can be programmed and used in various SIP scenarios.
		name = "LSP",
		w = { name = "Workspace" }
	},
	o = {
		name = "Symbols [O]utline",
		o = { "<cmd>SymbolsOutlineOpen<cr>", "Open symbols outline" },
		c = { "<cmd>SymbolsOutlineClose<cr>", "Close symbols outline" },
	},
	P = { "<cmd>Lazy<CR>", "Lazy [P]lugin UI" },
	t = {
		name = "File tree",
		t = { "<Cmd>NvimTreeFocus<Cr>", "File tree focus" },
		f = { "<Cmd>NvimTreeFindFile<Cr>", "File tree open current file" },
		c = { "<Cmd>NvimTreeClose<Cr>", "File tree Close" },
		C = { "<Cmd>NvimTreeCollapse<Cr>", "File tree Close" },
	},
	u = {
		name = "Undo Tree",
		u = { "<Cmd>UndotreeShow<Cr><Cmd>UndotreeFocus<Cr>", "Undo tree open and focus" },
		c = { "<Cmd>UndotreeHide<Cr>", "Undo tree Close" }
	},
	x = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace current word" },
}

which_key.setup(conf)
which_key.register(mappings, opts)
