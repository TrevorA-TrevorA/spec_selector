**version 0.1.6** 

Corrected a test rerun bug as well as a problem with key control regex patterns; made a slight modification to key controls: T is no longer case-sensitive and will now rerun the top failed test result from the current set. To view the top failed result from the current set without rerunning, press SPACEBAR.

**version 0.1.7** 

Updated key control instructions display text.

**version 0.1.8** 

Removed unnecessary files from build.

**version 0.1.9** 

Updated certificates

**version 0.2.0**

Added functionality to log secondary stderr and stdout content to tempfiles that can be viewed during a session.

Since SpecSelector is an RSpec formatter, all of the interactive content and example details that appear in the terminal window are printed through the `RSpec::Core::OutputWrapper` object that is passed into the constructor. This is basically just a wrapper for STDOUT. Error messages from exceptions that prevent tests from running ("errors outside of examples") are wrapped in `RSpec::Core::Notifications::MessageNotification` objects and passed to the #message method. These are the primary output and error content that appear when running tests. However, there is occasionally output that is not handled within these mechanisms, and under normal circumstances, such output would simply be printed to the terminal window. In this case, it is viewable with option keys. If you want to view information logged through stderr, press `e`. If you want to view information logged through stdout, press `o`. Information such as deprecation warnings generated during a spec run would be logged to stderr. Information such as output from `puts` statements that you have placed in your code would be logged to stdout. The option keys open their respective logs with the `less` command, so you would press `q` to close the them. The tempfiles are deleted when the session ends.

Other changes in this update:

- Logic that handles terminal operations was adjusted so that it does not clear the scrollback buffer. Now you can scroll back up to whatever you were doing before running tests.

- Unnecessary dependencies were removed

- The minimum ruby version was changed to 2.5.

- The certificates were updated.

**version 0.2.1**

Updated certificates