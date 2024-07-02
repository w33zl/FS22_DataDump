--[[
Dump global functions, tables, classes and variables to a file. The purpose is to better understand the Farming Simulator object model through reverse engineering.

With this a starting point, you can then use the console command 'dtSaveTable' from the mod 'PowerTools: Developer' to write whole Lua tables (and full table hierarchies) to file for further analysis.

Author:     w33zl
Version:    1.0.0
Modified:   2024-07-02

Changelog:

]]

DataDump = Mod:init()

DataDump:source("lib/DevHelper.lua")

function DataDump:loadMap(filename)
    self.g_powerTools = g_globalMods["FS22_PowerTools"]
end

function DataDump:consoleCommandDump(filename)
    print("Got it! Process started")
    self.executionTimer = DevHelper.measureStart("Processing global table took %.2f seconds")
    self.chunkTimer = DevHelper.measureStart()
    self.activeTable = self.__g
    self.triggerProcess = true
    self.chunkCount = 0
    self.output = {
        functions = {},
        classes = {},
        tables = {},
        fields = {}
    }
    self.stats = {
        functions = 0,
        classes = 0,
        tables = 0,
        fields = 0,
        total = 0,
    }
end


function DataDump:processChunk()
    --NOTE: Yes, this is over engineered, but it is prepared to handle a large number of tables in a deep structure
    local count = 0
    self.chunkCount = self.chunkCount + 1
    while true do
        count = count + 1
        local index, value = next(self.activeTable, self.last)
        self.last = index

        if self.last ~= nil then
            -- print(self.last)
            self.stats.total = self.stats.total + 1

            if type(value) == "function" then
                -- table.insert(self.output.functions, self.last)
                self.output.functions[self.last] = value
                self.stats.functions = self.stats.functions + 1
            elseif type(value) == "table" then
                local isClass = false
                if value.isa ~= nil and type(value.isa) == "function" then
                    isClass = value:isa(value) -- Should only be true on the actual class, but not on derived objects
                end
                if isClass then
                    -- table.insert(self.output.classes, self.last)
                    self.output.classes[self.last] = value
                    self.stats.classes = self.stats.classes + 1
                else
                    -- table.insert(self.output.tables, self.last)
                    self.output.tables[self.last] = value
                    self.stats.tables = self.stats.tables + 1
                end
            elseif type(value) == "userdata" then
                --TODO: need special care?
                self.output.fields[self.last] = value
                self.stats.fields = self.stats.fields + 1
                -- table.insert(self.output.fields, self.last)
            else
                self.output.fields[self.last] = value
                self.stats.fields = self.stats.fields + 1
                -- table.insert(self.output.fields, self.last)
            end
        end

        if self.last == nil or (self.chunkTimer:elapsed() > 1) or (count >= 500) then
            count = 0
            self.chunkTimer = DevHelper.measureStart()
            return self.last
        end
    end
end

function DataDump:update(filename)
    if not self.triggerProcess and not self.inProgress then
        return
    end

    self.triggerProcess = false
    self.inProgress = true

    local val = self:processChunk()
    if val == nil then
        self.inProgress = false
        self.executionTimer:stop()

        Log:info("Found %d functions, %d classes, %d tables and %d fields in %d chunks", self.stats.functions, self.stats.classes, self.stats.tables, self.stats.fields, self.chunkCount)

        -- DebugUtil.printTableRecursively(self.output, ":: ", 1)
        -- DebugUtil.printTableRecursively(g_globalMods, "g_globalMods:: ", 3)
        if self.g_powerTools ~= nil then
            self.g_powerTools:visualizeTable("Output", self.output, 3)
        else
            Log:warning("g_powerTools was not found, verify that the mod 'PowerTools: Developer' is enabled.")
            -- DebugUtil.printTableRecursively(self.output, ":: ", 2)
            end
        return
    else
        Log:info("#%d: Reading global table, found %d items so far... ", self.chunkCount, self.stats.total)
    end
end


addConsoleCommand("ddDump", "", "consoleCommandDump", DataDump)


