--  Create a function that turns
--  \refwithranges[fig:a, fig:b, fig:c, fig:x, fig:z]
--  into
--  Figures 1-3,24,26

local report = logs.reporter("inrange")
local errorcode = -99

-- Given an array of numbers, return an array of runs in that list.
-- Each run is itself an array with elements ["start"] and ["stop"]
-- Pre-sorting is left in the user's hands
local function get_runs(a)
    runs = { }
    run_start = 1
    while run_start <= #a do
        run_stop = run_start
        -- TODO replace a[run_stop] + 1 with
        -- increment_number_string(a[run_stop])
        -- that turns '1.2.1' into '1.2.2'
        -- so we can get runs among prefixed numbers, too.
        if a[run_stop] <= -100 then
            report("Ignoring entry %d", a[run_stop])
        else
            while a[run_stop + 1] == a[run_stop] + 1 do
                run_stop = run_stop + 1
            end
            report("%s--%s", run_start, run_stop)
            table.insert(runs, {["start"] = a[run_start],
                                ["stop"]   = a[run_stop]})
        end
        run_start = run_stop + 1
    end
    return runs
end

-- Given a reference string, return the figure/section/table number
-- Yes, invoking this on multiple strings operates in quadratic time.
-- Solution: assume n to be small
-- A helper function for this should exist somewhere
local function number_from_ref(refstring)
    -- TODO ensure we only run when structures.lists.ordered.float
    -- already exists
    for k,v in pairs(structures.lists.ordered.float.figure) do
        -- TODO if we return the full '1.2.1' string here
        -- then adapt get_runs as stated there, we can process prefixed
        -- numbers, too.
        if refstring == v.references.reference then
            report("%s --> %d", refstring, v.numberdata.numbers[1])
            return v.numberdata.numbers[1]
        end
    end
    errorcode = errorcode - 1
    report("Unknown reference: %s, returning %d", refstring, errorcode)
    return errorcode
end


-- Input: an array of runs,
-- Action: print something like '1, 3-5, and 8'
local function typeset_runs(runs, args)
    args = args or { }
    range_char = args["range_char"] or '-'
    run_sep = args["run_sep"] or ', '
    last_sep = args["last_sep"] or run_sep

    local i = 0
    for _, run in pairs(runs) do
        if 0 < i and i < #runs - 1 then
            context(run_sep)
        end
        if 0 < i and i == #runs - 1 then
            context(last_sep)
        end
        i = i + 1

        context("\\in[%s]", run.start)
        if run.start ~= run.stop then
            context("%s\\in[%s]", range_char, run.stop)
        end
    end
end

-- User-facing function: 
local function inrange(str)
    if not structures.lists.ordered["float"] then
        -- float table does not yet exist, do nothing this run
        return false
    end

    local refstrings_unsorted = utilities.parsers.settings_to_array(str)
    local refstrings = { }
    local numbers = { }

    -- turn refstrings into numbers, and remember what goes with what
    for _, ref in pairs(refstrings_unsorted) do
        local n = number_from_ref(ref)
        table.insert(numbers, n)
        refstrings[n] = ref
    end
    -- sort the numbers, and turn them into a runs table
    table.sort(numbers)
    local runs = get_runs(numbers)

    -- replace the numbers in the runs table with refstrings, and
    -- typeset
    for k, run in pairs(runs) do
        runs[k].start = refstrings[run.start]
        runs[k].stop = refstrings[run.stop]
    end
    typeset_runs(runs, {last_sep = ' and '})
end

userdata = userdata or { }
u = userdata
u.get_runs = get_runs
u.inrange = inrange
