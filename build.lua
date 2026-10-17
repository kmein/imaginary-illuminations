-- build the site into dist/ (or the directory given as argument) from plates.lua
local plates = dofile("plates.lua")
local OUT = arg[1] or "dist"
local TITLE = "Imaginary Illuminations"
local MONTHS = { "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December" }

local HEAD = [[
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>%s</title>
<link rel="icon" href="avatar.jpg">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;1,400&display=swap">
<link rel="stylesheet" href="style.css">
</head><body>
]]

local ESCAPES = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;", ['"'] = "&quot;", ["'"] = "&#x27;" }
local function escape(s) return (s:gsub("[&<>\"']", ESCAPES)) end

local function id(n) return string.format("%03d", n) end

local function long_date(iso)
  local y, m, d = iso:match("(%d+)-(%d+)-(%d+)")
  return string.format("%d %s %s", tonumber(d), MONTHS[tonumber(m)], y)
end

local function caption(p)
  return escape((p.caption:gsub("^%l", string.upper)))
end

local function write(path, s)
  local f = assert(io.open(OUT .. "/" .. path, "w"))
  f:write(s)
  f:close()
end

local function index()
  local figures = {}
  for _, p in ipairs(plates) do
    figures[#figures + 1] = string.format(
      '<a class="plate" id="pl%s" href="%s.html" title="%s">'
      .. '<img src="img/%s.png" width="%d" height="%d" alt="%s" loading="lazy">'
      .. '<span class="no">Pl. %d</span></a>',
      id(p.n), id(p.n), caption(p), id(p.n), p.width, p.height, caption(p), p.n)
  end
  local first, last = plates[1].date, plates[1].date
  for _, p in ipairs(plates) do
    if p.date < first then first = p.date end
    if p.date > last then last = p.date end
  end
  return HEAD:format(TITLE) .. string.format([[
<header class="masthead">
<h1>%s</h1>
<p class="sub">Beautiful illuminated manuscripts that never existed</p>
<p class="period">%s – %s</p>
<p class="rule">❧</p>
</header>
<main>
<div class="grid">
%s
</div>
</main>
</body></html>
]], TITLE, long_date(first), long_date(last), table.concat(figures, "\n"))
end

local function nav(q, rel, label)
  if q then return string.format('<a rel="%s" href="%s.html">%s</a>', rel, id(q.n), label) end
  return string.format("<span>%s</span>", label)
end

local function page(p, prev, next_)
  local pid = id(p.n)
  local cap = p.caption ~= "" and string.format('<p class="caption">%s</p>', caption(p)) or ""
  return HEAD:format(string.format("Plate %d · %s", p.n, TITLE)) .. string.format([[
<header class="running">
<a href="index.html#pl%s">%s</a>
</header>
<main class="single">
<figure>
<a href="img/%s.png"><img src="img/%s.png" width="%d" height="%d" alt="%s"></a>
<figcaption>
<h1><span class="label">Plate</span> %d</h1>
%s
<p class="meta">First shown %s · <a href="%s">original post</a></p>
</figcaption>
</figure>
<nav>
%s
<a href="index.html#pl%s">Catalogue</a>
%s
</nav>
</main>
<script>
addEventListener("keydown", e => {
  const a = document.querySelector({ArrowLeft: "a[rel=prev]", ArrowRight: "a[rel=next]"}[e.key]);
  if (a && !e.altKey && !e.metaKey && !e.ctrlKey) location = a.href;
});
</script>
</body></html>
]], pid, TITLE, pid, pid, p.width, p.height, caption(p), p.n, cap, long_date(p.date), escape(p.url),
    nav(prev, "prev", prev and "← Pl. " .. p.n - 1 or "←"),
    pid,
    nav(next_, "next", next_ and "Pl. " .. p.n + 1 .. " →" or "→"))
end

assert(os.execute(string.format("rm -rf '%s' && mkdir -p '%s' && cp -rl img style.css avatar.jpg '%s'", OUT, OUT, OUT)))
write("index.html", index())
for i, p in ipairs(plates) do
  write(id(p.n) .. ".html", page(p, plates[i - 1], plates[i + 1]))
end
print(#plates .. " plates")
