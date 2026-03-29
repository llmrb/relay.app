# frozen_string_literal: true

##
# A task monitor that runs a list of tasks in parallel
# and monitors them afterwards. When a task fails, the
# monitor will exit and kill all other tasks.
#
# A {Relay::Task} becomes a process group leader, so killing
# the process group will kill all processes in the group which
# includes the task and all of its subprocesses.
class Relay::TaskMonitor
  ##
  # @param [Array<String>] tasks
  #  A list of task names
  # @return [Relay::TaskMonitor]
  def initialize(tasks:)
    @tasks = tasks.map { Relay::Task.new(_1) }
    @pids = []
  end

  ##
  # Assign a block that is run before tasks are forked
  # @return [void]
  def prefork(&block)
    @prefork = block
  end

  ##
  # Start the task monitor
  # @return [void]
  def monitor
    @prefork&.call
    run
    wait
  rescue Interrupt
    @pids.each { Process.kill("TERM", -_1) }
    wait
  end

  private

  ##
  # Run all tasks in parallel and monitor their status
  # @return [void]
  def run
    @pids = @tasks.map(&:call)
    @tasks.each do |task|
      if error?(task.status)
        break(@tasks.size - 1)
      end
    rescue Chan::WaitReadable
      sleep 0.05
      retry
    end
  end

  ##
  # Wait for all tasks to finish
  # @return [void]
  def wait
    @pids.each { Process.wait(_1) }
  end

  ##
  # Read the status of a task
  # @param [String] status
  #   Either "success" or "error"
  # @return [Boolean]
  def error?(status)
    case status
    when "error"
      @tasks.each do
        Process.kill("TERM", -_1.pid)
      rescue Errno::ESRCH
      end
      true
    when "success" then false
    end
  end
end
