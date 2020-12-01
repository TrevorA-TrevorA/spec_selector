module SpecSelectorUtil
   module State
    def rerun
      clear_frame
      italicize('running examples...')
      working_dir = Dir.pwd
      process_id = Process.pid
      args = ARGV.join(" ")
      reset = File.dirname(__FILE__) + '/scripts/reset.sh'
      Signal.trap('TERM') { clear_frame; exit }
      system("#{reset} #{process_id} #{working_dir} #{$0} #{args}")
    end
  end
end