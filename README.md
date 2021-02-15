# spec_selector

SpecSelector is an RSpec formatter than opens a utility menu in your terminal window when you run tests (rather than just printing static text). The utility allows you to select, view, filter, and rerun specific test results with simple key controls. 

**view test results**

Upon finishing the test run, the test result tree appears as a formatted list of top-level example groups. Select an example group to view its subgroups, select a subgroup to view its examples, and so on. You can view your test results with the selection tool, or just press T to immediately view the top failed test. 

**filter and rerun test results**

Using the selection tool, press M to add the selected group or example to the inclusion filter. Press R to rerun RSpec with only selected tests.

Without using the selection tool, press F to rerun only failed tests. Press SHIFT + T to rerun only the top failed test.

Press C to clear the inclusion filter. Press A to clear the inclusion filter and rerun RSpec with all tests.

Press V to view the inclusion filter as a selection list. 

_Filter Modes_

Whenever the inclusion filter is not empty, the filter mode will display at the top center of the terminal window. 

There are two filter modes: _description_ and _location_. 

The filter always uses description matching by default, but will use location (line number) matching if examples without descriptions (i.e. "one-liners") are selected for inclusion.

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

**Author**

Trevor Almon
 
