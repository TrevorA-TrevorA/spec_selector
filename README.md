# spec_selector

spec_selector is an interactive 'custom formatter' for RSpec that facilitates quick navigation and filter control of example run results. 

How it works:

At the end of an example run, spec_selector displays a list of top-level
example groups. Select an example group to view its subgroups. Press backspace to view the list that includes the parent of the current list.
<img src="gifs/spec_selector_demo_1.gif" height="500"/>

Select an example to view a result summary. The summary page of a failed or pending example will display all of the usual information about why it failed or is pending. Press T at any point to view the top failed example. Press escape to return to the top-level list.

<img src="gifs/spec_selector_demo_2.gif" height="500"/>

spec_selector enables quick inclusion filtering. Press M to mark the selected example or example group for inclusion in the next run. Press R to rerun examples with the filter selection (or to rerun all examples if the filter is empty). 
<img src="gifs/spec_selector_demo_3.gif" height="500"/>

Press F to rerun only failed examples.
<img src="gifs/spec_selector_demo_4.gif" height="500"/>

Press C to clear the inclusion filter at any time. Press A to clear the inclusion filter and rerun all examples. 
<img src="gifs/spec_selector_demo_5.gif" height="500"/>

If unsure how to perform an action, press I to view the instructions
<img src="gifs/spec_selector_demo_6.gif" height="500"/>
