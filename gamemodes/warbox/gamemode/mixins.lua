
Mixins = Mixins or {}
Mixins.IgnoreKeys = {
    MixinInitialize = "A function which copies the mixins behaviour to the subclass."
    , expectedMixins = "Mixin dependencies a mixin requires to function."
    , expectedCallbacks = "Callback dependencies a mixin requires to function."
    , optionalCallbacks = "Callbacks which a mixin calls. The are optional and are really only "
            .. "listed to expose the functionality to readers. In a similar vein,"
            .. "listing methods used by mixin that might be desireable to override is also useful."
}

--- Entities are tables
local SubclassTypes = {["table"] = true, ["Entity"] = true}


--- This function is used to create a mixin-table.
-- If mixin has already been created, preserves the table-ref and just empties it.
-- There wont exist multiple copies at different references even if mixin is created multiple times.
-- <br>
-- Normally GC would handle such a case, but considering the mixin is likely to be registered on
-- tables after `include()`, odds are it will remain in memory tied to the tables.
-- <br>
-- In addition, it has benefits during hotloading as changes are made in the existing table.
-- <p>
-- This also makes the number of references to `NewBaseClassSafeTable` fewer.
-- <p>
-- ex. `ExampleMixin = CreateMixin(ExampleMixin)`
-- `ExampleMixin == nil` the first time the line executes.
-- @param mixin The existing mixin-table, may be nil.
-- @param name Sets the mixin.MixinName field if given.
-- Do note that nothing enforces that this is a unique name.
-- A mixin is expected to have a name, but it is fine to set it at a later stage.
-- @return The created mixin-table. Reuses `mixin` when given.
function Mixins.CreateMixin(mixin, name)
    mixin = mixin or NewBaseClassSafeTable()
    assert(type(mixin) == "table")
    for k in pairs(mixin) do
        mixin[k] = nil
    end
    
    for k,v in pairs(mixin) do
        if (v and type(v) == "table") then
            mixin[k] = (v.isBaseClassSafe and v) or NewBaseClassSafeTable(v)
        end
    end
    
    mixin.MixinName = name
    
    mixin.MixinInitialize = function(subclass)
        assert(SubclassTypes[type(subclass)], "Expected 'subclass' to be of type 'table', but received "
                .. type(subclass) .. " instead.")
        
        subclass.mixinDispatchers = subclass.mixinDispatchers or NewBaseClassSafeTable()
        
        Mixins.AssertExpectedMixins(subclass, mixin)
        
        Mixins.AssertExpectedCallbacks(subclass, mixin)
        
        for k, v in pairs(mixin) do
            if not Mixins.IgnoreKeys[k] and (subclass.OverrideMixins[k] == nil
                    or (type(subclass.OverrideMixins[k]) == "table"
                    and not subclass.OverrideMixins[k][mixin.MixinName])) then
                if type(v) == "function" then
                    local subclassFunc = subclass[k]
                    local dispatcher
                    
                    --if (subclassFunc == nil or type(subclassFunc) == "function") then
                    if (subclassFunc == nil or not subclass.mixinDispatchers[k]) then
                        mt = {
                            __call = function(self, ...)
                                local fst
                                for _, f in pairs(self.functionList) do
                                    if fst then
                                        f( ... )
                                    else
                                        fst = f( ... )
                                    end
                                end
                                return fst
                            end
                            , functionList = {}
                            , functionSet = {}
                            , isDispatcher = true
                        }
                        mt.__index = mt
                        dispatcher = setmetatable({}, mt)
                        subclass.mixinDispatchers[k] = dispatcher
                        --subclass[k] = dispatcher
                        subclass[k] = function( ... ) return dispatcher( ... ) end
                        if subclassFunc then
                            table.insert(dispatcher.functionList, subclassFunc)
                            dispatcher.functionSet[subclassFunc] = #dispatcher.functionList
                        end
                    --elseif (type(subclassFunc) == "table" and subclassFunc.isDispatcher) then
                    elseif (subclass.mixinDispatchers[k] and subclass.mixinDispatchers[k].isDispatcher) then
                        --dispatcher = subclass[k]
                        dispatcher = subclass.mixinDispatchers[k]
                    else
                        error("Tried to add function from mixin " .. tostring(mixin)
                                .. "to field '" .. k .. "' of " .. tostring(subclass)
                                .. ", but type was neither function nor was it a dispatcher.")
                    end
                    if not dispatcher.functionSet[v] then
                        table.insert(dispatcher.functionList, v)
                        dispatcher.functionSet[v] = #dispatcher.functionList
                    end
                else
                    -- TODO I probably want most fields copied over too
                    if not subclass[k] then
                        subclass[k] = v
                    end
                end
            end
        end
    end
    
    return mixin
end


--- Function to check if a table contains a specified mixin.
-- @param subclass The table to inspect
-- @param mixin Either the mixin-table to ascertain, or its `Name`.
-- @return True if table contains mixin.
function Mixins.HasMixin(subclass, mixin)
    assert(SubclassTypes[type(subclass)], "Expected 'subclass' to be of type 'table', but received "
            .. type(subclass) .. " instead.")
    assert(type(mixin) == "table" or type(mixin) == "string"
            , "Expected table or string, but given mixin is of type " .. type(mixin) .. ".")
    
    if (type(mixin) == "table") then
        assert(mixin.MixinName)
        mixin = mixin.MixinName
    end
    return subclass.Mixins[mixin] ~= nil
end


--- Function that assert mixins mixin-dependencies.
function Mixins.AssertExpectedMixins(subclass, mixin)

    mixin.expectedMixins = mixin.expectedMixins or {}
    assert(type(mixin.expectedMixins) == "table")
    
    for expectedName, _ in pairs(mixin.expectedMixins) do
        assert(Mixins.HasMixin(subclass, expectedName)
                , tostring(subclass) .. ": The mixin " .. mixin.MixinName
                .. " expects mixin '" .. expectedName
                .. "', but it is not present.")
    end
end


--- Function that assert mixins callback-dependencies.
function Mixins.AssertExpectedCallbacks(subclass, mixin)

    mixin.expectedCallbacks = mixin.expectedCallbacks or {}
    assert(type(mixin.expectedCallbacks) == "table")
    
    for callbackName, _ in pairs(mixin.expectedCallbacks) do
        assert(subclass[callbackName]
                , tostring(subclass) .. ": The mixin " .. mixin.MixinName
                .. "' expects callback '" .. callbackName
                .. "', but it is not present.")
        assert(type(subclass[callbackName]) == "function"
                , tostring(subclass) .. ": The mixin '" .. mixin.MixinName
                .. "' expects callback '" .. callbackName
                .. "', but the present value " .. tostring(subclass[callbackName])
                .. " is of non-function type '" .. type(subclass[callbackName]) .. "'.")
    end

end


--- Function that 'registers' a mixin in a table.
-- This means the specified mixin will be added to the table `Mixins`-field indexed by `mixin.Name`
-- As such, given that the mixins are registered properly,
-- no duplicate references should exist nor should there be any mixins sharing the same `Name`.
-- @param subclass The table to register the mixin.
-- @param mixin The mixin to be registered to the table.
function Mixins.RegisterMixin(subclass, mixin)
    assert(SubclassTypes[type(subclass)], "Expected 'subclass' to be of type 'table', but received "
            .. type(subclass) .. " instead.")
    assert(type(mixin) == "table", "Expected 'table', received " .. type(mixin) .. ".")
    
    -- Avoid infinite recursion from garrys BaseClass'ing-system
    for k,v in pairs(mixin) do
        if (v and type(v) == "table") then
            mixin[k] = (v.isBaseClassSafe and v) or NewBaseClassSafeTable(v)
        end
    end
    
    -- If subclass.OverrideMixins["FunctionName"] is nil, nothing is overriden.
    -- If it is an empty table, everything is.
    -- To 'blacklist' specific mixins, make it a table where mixins whose MixinName's
    -- are used as keys for a non-nil value are blacklisted: `{mixin.MixinName = non-nil}`.
    subclass.OverrideMixins = subclass.OverrideMixins or NewBaseClassSafeTable()
    
    -- All mixins are added to the subclass.Mixins table, indexed by their name.
    subclass.Mixins = subclass.Mixins or NewBaseClassSafeTable()
    
    -- Simplest fix is by never adding it if it already exists.
    if subclass.Mixins[mixin.MixinName] ~= mixin then
        subclass.Mixins[mixin.MixinName] = mixin
    end
    
    -- Shortcuts/aliases from entity
    subclass.InitializeMixins = Mixins.InitializeMixins
    subclass.PostInitializeMixins = Mixins.PostInitializeMixins
end


--- Function that initializes all mixins in a table.
-- When a mixin is initialized it:
--  Asserts that its dependencies are fulfilled
--  Copies the key-value pairs to the table if current value is nil, 
--  Creates and adds dispatchers for functions (existing functions are added to dispatcher).
-- Any key-value pair where the mixin has been 'overridden' is ignored.
-- Set `subclass.OverrideMixins[key]["MixinName"] to a non-nil value to override a mixin.
-- @param subclass The table whose mixins to initialize.
function Mixins.InitializeMixins(subclass)
    assert(SubclassTypes[type(subclass)], "Expected 'subclass' to be of type 'table', but received "
            .. type(subclass) .. " instead.")
    
    -- Pass silently if subclass.Mixins is nil.
    if (subclass.Mixins) then
        assert(type(subclass.Mixins) == "table")
        
        local orderedMixins = {}
        subclass.seenMixins = subclass.seenMixins or NewBaseClassSafeTable()
        local BaseClassFirst
        BaseClassFirst = function(m)
            for k, v in pairs(m) do
                if k ~= "BaseClass" then
                    table.insert(orderedMixins, v)
                end
            end
            if (type(m.BaseClass) == "table") then
                BaseClassFirst(m.BaseClass)
            end
        end
        BaseClassFirst(subclass.Mixins)
        for i = #orderedMixins, 1, -1 do
            if not subclass.seenMixins[orderedMixins[i]] then
                subclass.seenMixins[orderedMixins[i]] = i
                orderedMixins[i].MixinInitialize(subclass)
                if orderedMixins[i].MixinPreInitialize then
                    orderedMixins[i].MixinPreInitialize(subclass)
                end
            end
        end
    end
end

function Mixins.PostInitializeMixins(subclass)
    assert(SubclassTypes[type(subclass)], "Expected 'subclass' to be of type 'table', but received "
            .. type(subclass) .. " instead.")
    
    -- Pass silently if there are no mixins with an Initialize function,
    -- or even if subclass.mixinDispatchers is nil.
    if subclass.mixinDispatchers and subclass.mixinDispatchers["Initialize"] then
        assert(type(subclass.mixinDispatchers["Initialize"].functionList) == "table")
        
        for k, v in ipairs(subclass.mixinDispatchers["Initialize"].functionList) do
            if k > 1 then
                v(subclass)
            end
        end
    end
end


--[[
--Test
A_Mixin = Mixins.CreateMixin(A_Mixin, "A")
function A_Mixin.blah(...)
    io.write("A_Mixin: blah(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
function A_Mixin.Foo(...)
    io.write("A_Mixin: Foo(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
function A_Mixin.Bar(...)
    io.write("A_Mixin: Bar(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
function A_Mixin.FooBar(...)
    io.write("A_Mixin: FooBar(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
function A_Mixin.FooBar2(...)
    io.write("A_Mixin: FooBar2(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
B_Mixin = Mixins.CreateMixin(B_Mixin, "B")
function B_Mixin.blah()
    io.write("B_Mixin: blah();  ")
end
function B_Mixin.Foo()
    io.write("B_Mixin: Foo();  ")
end
function B_Mixin.Bar()
    io.write("B_Mixin: Bar();  ")
end
function B_Mixin.FooBar()
    io.write("B_Mixin: FooBar();  ")
end
function B_Mixin.FooBar2()
    io.write("B_Mixin: FooBar2();  ")
end

SubClass = {}
Mixins.RegisterMixin(SubClass, A_Mixin)
Mixins.RegisterMixin(SubClass, B_Mixin)
function SubClass.blah(...)
    io.write("SubClass: blah(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
SubClass.OverrideMixins.Foo = {A = true}
function SubClass.Foo(...)
    io.write("SubClass: Foo(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
SubClass.OverrideMixins.Bar = {B = true}
function SubClass.Bar()
    io.write("SubClass: Bar();  ")
end
SubClass.OverrideMixins.FooBar = {A = true, B = true}
function SubClass.FooBar(...)
    io.write("SubClass: FooBar(")
    for _, v in pairs({...}) do
        io.write(tostring(v))
    end
    io.write(");    ")
end
SubClass.OverrideMixins.FooBar2 = true
function SubClass.FooBar2()
    io.write("SubClass: FooBar2();  ")
end
Mixins.InitializeMixins(SubClass)

SubClass.blah()
print()
SubClass.Foo("a", "b", "c")
print()
SubClass.Bar("a", "b", "c")
print()
SubClass.FooBar("a", "b", "c")
print()
SubClass.FooBar2("a", "b", "c")
print()
--]]
