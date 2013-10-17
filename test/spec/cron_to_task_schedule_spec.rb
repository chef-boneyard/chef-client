require_relative 'spec_helper'
require_relative '../../libraries/cron_to_task_schedule'

describe Opscode::ChefClient::Helpers do
  include Opscode::ChefClient::Helpers

  describe '#cron_to_task_schedule' do
    let(:now) { Time.now }
    let(:logger) { StringIO.new }
    before { Chef::Log.logger = Logger.new(logger) }

    it 'converts every minute' do
      frequency, modifier, start_time = cron_to_task_schedule('*', '*')
      expect(frequency).to eq :minute
      expect(modifier).to eq 1
      expect(start_time).to be_nil
    end

    it 'converts every minute with specific hour' do
      expect { cron_to_task_schedule('*', '5') }.to raise_error SystemExit
      expect(logger.string).to match /FATAL.*every minute of specific hour/
    end

    it 'converts every N minutes' do
      start_after = Time.new(now.year, now.month, now.day, 0, 0)
      frequency, modifier, start_time = cron_to_task_schedule('*/5', '*', start_after)
      expect(frequency).to eq :minute
      expect(modifier).to eq 12
      expect(start_time).to eq start_after
    end

    it 'converts every N minutes starting starting next interval' do
      start_after = Time.new(now.year, now.month, now.day, 0, 1)
      frequency, modifier, start_time = cron_to_task_schedule('*/5', '*', start_after)
      expect(frequency).to eq :minute
      expect(modifier).to eq 12
      expect(start_time).to eq (start_after + 11*60)
    end

    it 'converts every N minutes with specific hour' do
      expect { cron_to_task_schedule('*/5', '1') }.to raise_error SystemExit
      expect(logger.string).to match /FATAL.*every 12 minutes of specific hour/
    end

    it 'converts specific minute of every hour' do
      start_after = Time.new(now.year, now.month, now.day, 0, 6)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 1
      expect(start_time).to eq start_after
    end

    it 'converts specific minute of every hour starting later this hour' do
      start_after = Time.new(now.year, now.month, now.day, 0, 0)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 1
      expect(start_time).to eq (start_after + 6*60)
    end

    it 'converts specific minute of every hour starting next hour' do
      start_after = Time.new(now.year, now.month, now.day, 0, 7)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 1
      expect(start_time).to eq (start_after + 59*60)
    end

    it 'converts specific minute of every N hours' do
      start_after = Time.new(now.year, now.month, now.day, 0, 6)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*/4', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 6
      expect(start_time).to eq start_after
    end

    it 'converts specific minute of every N hours starting later minute this hour' do
      start_after = Time.new(now.year, now.month, now.day, 0, 0)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*/4', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 6
      expect(start_time).to eq (start_after + 6*60)
    end

    it 'converts specific minute of every N hours starting earlier minute next hour' do
      start_after = Time.new(now.year, now.month, now.day, 5, 7)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*/4', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 6
      expect(start_time).to eq (start_after + 59*60)
    end

    it 'converts specific minute of every N hours starting later minute next hour interval' do
      start_after = Time.new(now.year, now.month, now.day, 1, 0)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*/4', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 6
      expect(start_time).to eq (start_after + 6*60 + 5*60*60)
    end

    it 'converts specific minute of every N hours starting earlier minute next hour interval' do
      start_after = Time.new(now.year, now.month, now.day, 0, 7)
      frequency, modifier, start_time = cron_to_task_schedule('6', '*/4', start_after)
      expect(frequency).to eq :hourly
      expect(modifier).to eq 6
      expect(start_time).to eq (start_after + 59*60 + 5*60*60)
    end

    it 'converts specific minute of specific hour' do
      frequency, modifier, start_time = cron_to_task_schedule('0', '3')
      expect(frequency).to eq :daily
      expect(modifier).to eq 1
      expect(start_time).to eq Time.new(now.year, now.month, now.day, 3, 0)
    end

    it 'fails when the hour is not a valid cron schedule' do
      expect{cron_to_task_schedule('0', 'not valid')}.to raise_error SystemExit
      expect(logger.string).to match /Could not determine scheduled task schedule/
    end

    it 'fails when the mintute is not a valid cron schedule' do
      expect{cron_to_task_schedule('not valid', '0')}.to raise_error SystemExit
      expect(logger.string).to match /Could not determine scheduled task schedule/
    end
  end
end
