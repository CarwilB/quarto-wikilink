local function file_exists(path)
  local f = io.open(path, "rb")
  if f then f:close() return true end
  return false
end

-- Read and encode bundled icon once during compilation
local icon_path = quarto.project.resolve_path("wikipedia-icon.png") or "wikipedia-icon.png"
local icon_data_uri = ""

if file_exists(icon_path) then
  local f = io.open(icon_path, "rb")
  local binary_data = f:read("*all")
  f:close()
  icon_data_uri = "data:image/png;base64," .. quarto.base64.encode(binary_data)
end

return {
  ['wikilink'] = function(args, kwargs)
    local title = pandoc.utils.stringify(args[1] or "")
    if title == "" then return pandoc.Null() end

    -- Custom display label or default to title
    local label = args[2] and pandoc.utils.stringify(args[2]) or nil

    -- Wikipedia slug conversion
    local page_slug = title:gsub(" ", "_")
    local url = "https://en.wikipedia.org/wiki/" .. page_slug

    -- Icon styling
    local img = pandoc.Image("Wikipedia", icon_data_uri)
    img.attributes = {
      width = kwargs["size"] or "1em",
      style = "vertical-align: -0.15em; display: inline-block; border: none;"
    }

    local link_elements = { img }

    -- Append optional text label
    if label then
      table.insert(link_elements, pandoc.Space())
      table.insert(link_elements, pandoc.Str(label))
    end

    return pandoc.Link(link_elements, url, title)
  end
}