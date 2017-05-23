
-- TODO Would probably do better in utility.lua than as a mixin

assert(Mixins)

QueryableTagMixin = Mixins.CreateMixin( QueryableTagMixin, "QueryableTag" )

QueryableTagMixin.expectedMixins =
{
}

QueryableTagMixin.expectedCallbacks =
{
}

QueryableTagMixin.optionalCallbacks =
{
    OnRemovedTag = "Called when a tag is removed.",
}


--- It shold be faster to use pre-populated tables when searching for entities by class,
-- than using ents.FindByClass as it `works internally by iterating over ents.GetAll.`
-- Granted this should only hold true when the tag is a minority,
-- considering FindByClass is likely performing at c-level.
local tags = tags or {}

--- Gmod callback
function QueryableTagMixin:Initialize()
end


--- Function that adds a tag to a table (and adds table to tag-table).
-- @param tag A string with name of tag
-- @param removeCallback An optional callback which is called by RemoveTag if given.
function QueryableTagMixin:AddTag(tag, removeCallback)
    self.QueryableTags = self.QueryableTags or {}
    if not self.QueryableTags[tag] then
        self.QueryableTags[tag] = removeCallback or true
        
        if tags[tag] then
            table.insert(tags[tag], self)
        else
            tags[tag] = {self}
        end
    end
end

--- Function that removes a tag from a table (and removes table from tag-table).
-- @param tag A string with name of tag
function QueryableTagMixin:RemoveTag(tag)
	for k,v in pairs(tags[tag]) do
		if (self == v) then
			table.remove(tags[tag], k)
            if type(self.QueryableTags[tag]) == "function" then
                self.QueryableTags[tag]()
            end
            self.QueryableTags[tag] = nil
            if self.OnRemovedTag then self:OnRemovedTag(tag) end
			break
		end
	end
end


function QueryableTagMixin.GetTableReference(tag)
	return tags[tag] -- Copying steals performance, this is better used when table wont be modified.
end
function QueryableTagMixin.GetTable(tag)
	return table.Copy(tags[tag])
end
