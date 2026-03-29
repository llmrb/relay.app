# frozen_string_literal: true

##
# {Relay::Task} represents a Rake task that can be run
# in a separate process. The process becomes a group leader,
# so that if it spawns any child processes, they will be in
# the same process group.
#
# A task provides its status through a channel, which can be
# either "success" or "error" depending on whether the task
# completed successfully or not.
class Relay::Task
  require "xchan"

  ##
  # @return [Chan::UNIXSocket]
  attr_reader :ch

  ##
  # @return [Integer]
  attr_reader :pid

  ##
  # @param [String] task
  #  The name of the Rake task to run
  # @return [void]
  def initialize(task)
    @task = task
    @ch = xchan(:pure)
    @pid = nil
  end

  ##
  # Call the task in a separate process
  # @return [Integer]
  #  The PID of the child process
  def call
    @pid = fork do
      become_group_leader
      invoke_task
      record_success
    rescue
      record_error
    end
  end

  ##
  # Read the status of a task (non-blocking)
  # @raise [Chan::WaitReadable]
  #   When the channel is not ready to be read
  # @return [String]
  #  Either "success" or "error"
  def status
    return @status if defined?(@status)
    @status = ch.recv_nonblock
  end

  private

  def become_group_leader = Process.setpgrp
  def invoke_task = Rake::Task[@task].invoke

  def record(status) = @ch.send(status)
  def record_success = record("success")
  def record_error = record("error")
end
