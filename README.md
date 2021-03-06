# spec_selector

SpecSelector is an RSpec formatter that opens a utility menu in your terminal window when you run tests (rather than just printing static text). The utility allows you to select, view, filter, and rerun specific test results with simple key controls. 

**View test results**

Upon finishing the test run, the test result tree appears as a formatted list of top-level example groups. Select an example group to view its subgroups, select a subgroup to view its examples, and so on. You can view your test results with the selection tool, or just press T to immediately view the top failed test. 

**Filter and rerun test results**

Using the selection tool, press M to add the selected group or example to the inclusion filter. Press R to rerun RSpec with only selected tests.

Without using the selection tool, press F to rerun only failed tests. Press SHIFT + T to rerun only the top failed test.

Press C to clear the inclusion filter. Press A to clear the inclusion filter and rerun RSpec with all tests.

Press V to view the inclusion filter as a selection list. 

_Filter Modes_

Whenever the inclusion filter is not empty, the filter mode will display at the top center of the terminal window. 

There are two filter modes: _description_ and _location_. 

The filter always uses description matching by default, but will use location (line number) matching if examples without descriptions (i.e. "one-liners") are selected for inclusion.

**Usage notes**

_Text color_

An example description will appear in red text if the example failed, yellow text if the example is pending, or green text if the example passed.

The color of an example group description is determined by the result status of its examples or recursively by the examples of its subgroups. The description will appear in red text if at least one failed example is present in its tree (e.g. if it contains a subgroup that contains a failed example), yellow text if its tree contains no failed examples and at least one pending example, or green text if every example in its tree passed.

_key controls_

BACKSPACE: View the list that contains the parent of the current list or example result summary.

ENTER/RETURN: Select an example group or example from the result list.

ESCAPE: Return to the top-level result list. If already viewing the top-level list, the escape key has no effect.

UP/DOWN: Navigate up and down the result list, or, if viewing an example result summary, view the next or previous example result summary.

A: Clear the inclusion filter and rerun RSpec with all examples.

C: Clear the inclusion filter.

F: Rerun RSpec with only failed examples from the current result set.

I: View or exit instructions.

M: Include or remove an example or example group from the inclusion filter.

P: Hide or reveal passing examples in the current result set.

R: Rerun RSpec with only examples and example groups marked for inclusion.

T: View the top failed example result summary from the current result set.

SHIFT + T: Rerun RSpec with only the top failed example from the current result set.

V: View the inclusion filter as a list.

Q: Exit spec_selector.



**Installation**

````
gem install spec_selector
````

Once installed, add the following line to your .rspec file:

````
--format SpecSelector
````

Or, use the -f option on the command line

````
rspec -f SpecSelector
````
  


**Author:** Trevor Almon\
**License:** MIT License\
**rubygems url:** https://rubygems.org/gems/spec_selector




 
