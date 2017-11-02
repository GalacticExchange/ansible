require_relative '../spec_helper'

flow = ClusterDeleteWorkflow.create(99)
flow.start!

puts 'OK'