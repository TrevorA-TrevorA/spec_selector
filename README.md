spec_selector is an interactive 'custom formatter' for RSpec that facilitates quick navigation and filter control of example run results. 

How it works:

At the end of an example run, spec_selector displays a list of top-level
example groups. Select an example group to view its subgroups. Select a bottom-level group to view a list of its examples. Press backspace to view the list that includes the parent of the current list.

Select an example to view a result summary. The summary page of a failed or pending example will display all of the usual information about why it failed or is pending.
Press T at any point to view the top failed example. Press escape to return to the top-level list.

spec_selector enables quick inclusion filtering. Press M to mark the selected example or example group for inclusion in the next run. Press R to rerun examples with the filter selection (or to rerun all examples if the filter is empty). 

Press F to rerun only failed examples. If any of them are now passing, they will appear green. Press T to skip to the top fail.

Press C to clear the inclusion filter at any time.
Press A to clear the inclusion filter and rerun all examples. 