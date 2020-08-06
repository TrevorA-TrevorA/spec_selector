require 'stringio'

describe SpecSelector do
    subject(:spec_selector){ SpecSelector.new(StringIO.new) }
    let(:_) { RSpec::Core::Notifications }
    let(:output) { spec_selector.ivar(:@output).string }

    let(:example_stubs) { {description: "description",
                        execution_result: "result",
                        full_description: "full_description"} }
    

    let(:pass_result) { instance_double("ExecutionResult", status: :passed)}
    let(:pending_result) { instance_double("ExecutionResult", status: :pending)}
    let(:fail_result) { instance_double "ExecutionResult", 
                                        status: :failed, 
                                        exception: "error",
                                        pending_fixed?: nil }

    let(:pass_stubs) { example_stubs.merge(execution_result: pass_result) }
    let(:pending_stubs) { example_stubs.merge(execution_result: pending_result) }
    let(:fail_stubs) { example_stubs.merge(execution_result: fail_result) }
    let(:passing_example) { instance_double("Example", pass_stubs) }
    let(:pending_example) { instance_double("Example", pending_stubs) }
    let(:failed_example) { instance_double("Example", fail_stubs) }

    describe "#message" do
        let(:notification) { _::MessageNotification.new("message") } 
        
        it 'outputs the message string from notification object' do 
            spec_selector.message(notification)
            expect(output).to eq("message\n")
        end
    end

    describe "#example_group_started" do
        let (:group) { RSpec::Core::ExampleGroup.new }
        let(:group_notification) { _::GroupNotification.new(group) }
        let (:groups) { spec_selector.ivar(:@groups) }

        it 'stores example group in @groups array' do
            spec_selector.example_group_started(group_notification)
            expect(groups).to include(group)
        end
    end

    describe "#example_passed" do
        let(:notification) { _::ExampleNotification.send(:new, passing_example) }
        let(:passed) { spec_selector.ivar(:@passed) } 

        before { spec_selector.example_passed(notification) }

        it "stores example description in @passed array" do
            expect(passed).to include("description")
        end

        it "increments @pass_count" do
            expect(spec_selector.ivar(:@pass_count)).to eq(1)
        end

        it "updates passing example status display" do
            expect(output).to match(/PASS: \d+/)
        end
    end

    describe "#example_pending" do
        let(:notification) { _::ExampleNotification.send(:new, pending_example) }
        let(:pending) { spec_selector.ivar(:@pending) } 

        before { spec_selector.example_pending(notification) }

        it "stores example description in @pending array" do
            expect(pending).to include("description")
        end

        it "increments @pending_count" do
            expect(spec_selector.ivar(:@pending_count)).to eq(1)
        end

        it "updates pending status display" do
            expect(output).to match(/PENDING: \d+/)
        end
    end

    describe "#example_failed" do
        let(:notification) { _::FailedExampleNotification.send(:new, failed_example) }
        let(:failed) { spec_selector.ivar(:@failed) } 
        let(:fail_count) { spec_selector.ivar(:@fail_count) }

        before { spec_selector.example_failed(notification) }

        it "stores example description in @failed array" do
            expect(failed).to include("description")
        end

        it "increments @fail_count" do
            expect(fail_count).to eq(1)
        end

        it "calls #status count" do
            expect(output).to match(/FAIL: \d+/)
        end
    end

    describe "#dump_failures" do
    let(:configuration) { RSpec::Core::Configuration.new }
    let(:reporter) { RSpec::Core::Reporter.new(configuration) }
    let(:notification) { _::ExamplesNotification.new(reporter) }
    

        context "when no examples fail" do
            it "has no output" do
                allow(notification).to receive(:failed_examples){ [] }
                spec_selector.dump_failures(notification)
                expect(output).to be_empty
            end
        end

        context "when at least one example fails" do
            let(:failure_summaries) { spec_selector.ivar(:@failure_summaries) }
        
            it "stores failure information in @failure_summaries array" do
                allow(notification).to receive(:failed_examples) { [failed_example] }
                allow(notification).to receive(:fully_formatted_failed_examples) do
                    "fail!" 
                end

                spec_selector.dump_failures(notification)
                expect(failure_summaries).to include( "fail!" )
            end
        end
    end

    describe "#dump_pending" do

    let(:configuration) { RSpec::Core::Configuration.new }
    let(:reporter) { RSpec::Core::Reporter.new(configuration) }
    let(:notification) { _::ExamplesNotification.new(reporter) }
    

        context "when none of the examples result in pending status" do
            it "has no output" do
                allow(notification).to receive(:pending_examples){ [] }
                spec_selector.dump_pending(notification)
                expect(output).to be_empty
            end
        end

        context "when at least one example results in pending status" do
            let(:pending_summaries) do
                spec_selector.ivar(:@pending_summaries)
            end

            it "stores failure information in @pending_summaries array" do
                allow(notification).to receive(:pending_examples){ [pending_example] }
                allow(notification).to receive(:fully_formatted_pending_examples) do
                    "pending" 
                end

                spec_selector.dump_pending(notification)
                expect(pending_summaries).to include( "pending" )
            end
        end
    end

    describe "#dump_summary" do
        let(:summary_notification) do
            instance_double "SummaryNotification",
                            duration: 1.5,
                            example_count: 2,
                            examples: [failed_example, pending_example],
                            failed_examples: [failed_example],
                            pending_examples: [pending_example],
                            load_time: 0.37,
                            errors_outside_of_examples_count: 0 
        end

        it "displays a formatted summary of example results" do
            spec_selector.dump_summary(summary_notification)
            expect(output).to include("\e[3mTotal Examples: 2\e[0m")
            expect(output).to include("\e[3mFinished in 1.5 seconds\e[0m")
            expect(output).to include("\e[3mFiles loaded in 0.37 seconds\e[0m")
        end

        it "calls #display_groups" do
            expect(spec_selector).to receive(:display_groups)
            spec_selector.dump_summary(summary_notification)
        end
    end

end