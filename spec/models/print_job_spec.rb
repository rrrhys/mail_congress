require 'spec_helper'

describe PrintJob do
  describe '.enqueue' do
    before do
      @letter = Letter.new
      @letter.stubs(:id).returns(1)
      PrintJob.enqueue(@letter)
    end

    it 'will push a new print job to Resque' do
      PrintJob.should have_queued(@letter.id)
    end
  end

  describe '.perform' do
    context 'succesfull printing' do
      before do
        @cups_print_job = mock('PrintJob')
        @cups_print_job.stubs(:print).returns(true)
        @cups_print_job.stubs(:state).returns(:processing).
          then.returns(:completed)
        Cups::PrintJob::Transient.stubs(:new).returns(@cups_print_job)
        @letter = Factory.build(:letter)
        @letter.stubs(:to_pdf).returns('')
        Letter.stubs(:find).returns(@letter)
        PrintJob.perform(@letter.id)
      end

      it 'creates a print job' do
        Cups::PrintJob::Transient.should have_received(:new)
      end

      it 'prints the letter' do
        @cups_print_job.should have_received(:print)
      end

      it 'waits until the printing is complete' do
        # 2 loops then the conditional
        @cups_print_job.should have_received(:state).times(3)
      end

      it 'converts the letters to pdf' do
        @letter.should have_received(:to_pdf)
      end

      it 'marks the letter as printed' do
        @letter.should be_printed
      end
    end
    
    context 'unsuccesfull printing' do
      before do
        @cups_print_job = mock('PrintJob')
        @cups_print_job.stubs(:print).returns(true)
        @cups_print_job.stubs(:state).returns(:aborted)
        Cups::PrintJob::Transient.stubs(:new).returns(@cups_print_job)
        @letter = Factory.build(:letter)
        @letter.stubs(:to_pdf).returns('')
        @letter.stubs(:update_attribute)
        Letter.stubs(:find).returns(@letter)
        PrintJob.stubs(:enqueue)
        PrintJob.perform(@letter.id)
      end

      it 'waits until the printing is complete' do
        @cups_print_job.should have_received(:state).times(2)
      end

      it 'does not mark the letter as printed' do
        @letter.should_not have_received(:update_attribute)
      end

      it 'should re-enqueue the job' do
        PrintJob.should have_received(:enqueue).with(@letter)
      end
    end
  end

end
