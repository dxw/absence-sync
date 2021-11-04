require "date"
require_relative "./absence"

RSpec.describe Absence do
  let(:start_date) { Date.new(2000, 1, 1) }
  let(:end_date) { Date.new(2000, 2, 1) }

  describe ".new" do
    it "rejects an invalid type" do
      expect {
        Absence.new(
          type: :invalid,
          start_date: start_date,
          end_date: end_date
        )
      }.to raise_error("invalid is not a recognized absence type")
    end

    it "rejects a non-date start date" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: "2000-01-01",
          end_date: end_date
        )
      }.to raise_error("2000-01-01 is not a date")
    end

    it "rejects a non-date end date" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: start_date,
          end_date: "2000-02-01"
        )
      }.to raise_error("2000-02-01 is not a date")
    end

    it "rejects an end date before the start date" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: start_date,
          end_date: start_date - 1
        )
      }.to raise_error("An absence cannot end before it starts")
    end

    it "rejects an end meridiem before the start meridiem when the start and end dates are the same" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: start_date,
          end_date: start_date,
          start_meridiem: :pm,
          end_meridiem: :am
        )
      }.to raise_error("An absence cannot end before it starts")
    end

    it "rejects an invalid start meridiem" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: start_date,
          end_date: end_date,
          start_meridiem: :invalid
        )
      }.to raise_error("invalid is not a recognized meridiem")
    end

    it "rejects an invalid end meridiem" do
      expect {
        Absence.new(
          type: :holiday,
          start_date: start_date,
          end_date: end_date,
          end_meridiem: :invalid
        )
      }.to raise_error("invalid is not a recognized meridiem")
    end
  end

  describe "#type" do
    it "returns the initial type" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.type).to eq(:holiday)
    end

    it "is read-only" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence).not_to respond_to(:type=)
    end
  end

  describe "#start_date" do
    it "returns the initial start date" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.start_date).to eq(start_date)
    end

    it "is read-only" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence).not_to respond_to(:start_date=)
    end
  end

  describe "#end_date" do
    it "returns the initial end date" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.end_date).to eq(end_date)
    end

    it "is read-only" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence).not_to respond_to(:end_date=)
    end
  end

  describe "#start_meridiem" do
    it "returns the initial start meridiem" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        start_meridiem: :pm
      )

      expect(absence.start_meridiem).to eq(:pm)
    end

    it "defaults to AM" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.start_meridiem).to eq(:am)
    end

    it "is read-only" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        start_meridiem: :pm
      )

      expect(absence).not_to respond_to(:start_meridiem=)
    end
  end

  describe "#end_meridiem" do
    it "returns the initial end meridiem" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        end_meridiem: :am
      )

      expect(absence.end_meridiem).to eq(:am)
    end

    it "is read-only" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        end_meridiem: :am
      )

      expect(absence).not_to respond_to(:end_meridiem=)
    end
  end

  describe "#matches_type?" do
    it "returns true when the other absence is of the same type" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.matches_type?(other)).to be(true)
    end

    it "returns false when the other absence is of the a different type" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :sickness,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.matches_type?(other)).to be(false)
    end
  end

  describe "#adjacent_to?" do
    subject_start_date = Date.new(2000, 6, 1)
    subject_end_date = Date.new(2000, 7, 1)

    [
      # 1 day gap
      {
        name: "returns false when the other absence starts more than one day after the end of the subject",
        other: {
          start_date: subject_end_date + 2,
          end_date: subject_end_date + 30
        },
        expectation: false
      },
      {
        name: "returns false when the other absence ends more than one day before the start of the subject",
        other: {
          start_date: subject_end_date - 30,
          end_date: subject_end_date - 2
        },
        expectation: false
      },

      # next/previous day
      {
        name: "returns true when the other absence starts (AM) on the day after the end (PM) of the subject",
        other: {
          start_date: subject_end_date + 1,
          end_date: subject_end_date + 30,
          start_meridiem: :am
        },
        subject: {
          end_meridiem: :pm
        },
        expectation: true
      },
      {
        name: "returns true when the other absence ends (PM) on the day before the start (AM) of the subject",
        other: {
          start_date: subject_start_date - 30,
          end_date: subject_start_date - 1,
          end_meridiem: :pm
        },
        subject: {
          start_meridiem: :am
        },
        expectation: true
      },

      # same day
      {
        name: "returns true when the other absence starts (PM) on the same day as the end (AM) of the subject",
        other: {
          start_date: subject_end_date,
          end_date: subject_end_date + 30,
          start_meridiem: :pm
        },
        subject: {
          end_meridiem: :am
        },
        expectation: true
      },
      {
        name: "returns true when the other absence ends (AM) on the same day as the start (PM) of the subject",
        other: {
          start_date: subject_start_date - 30,
          end_date: subject_start_date,
          end_meridiem: :am
        },
        subject: {
          start_meridiem: :pm
        },
        expectation: true
      },

      # same day with overlap
      {
        name: "returns false when the other absence starts (AM) on the same day as the end (PM) of the subject",
        other: {
          start_date: subject_end_date,
          end_date: subject_end_date + 30,
          start_meridiem: :am
        },
        subject: {
          end_meridiem: :pm
        },
        expectation: false
      },
      {
        name: "returns false when the other absence ends (PM) on the same day as the start (AM) of the subject",
        other: {
          start_date: subject_start_date - 30,
          end_date: subject_start_date,
          end_meridiem: :pm
        },
        subject: {
          start_meridiem: :am
        },
        expectation: false
      },

      # full day overlap
      {
        name: "returns false when the other absence starts between the start and the end of the subject",
        other: {
          start_date: subject_start_date + 1,
          end_date: subject_end_date + 1
        },
        expectation: false
      },
      {
        name: "returns false when the other absence ends between the start and the end of the subject",
        other: {
          start_date: subject_start_date - 1,
          end_date: subject_end_date - 1
        },
        expectation: false
      },

      # covered
      {
        name: "returns false when the other absence is covered by the subject",
        other: {
          start_date: subject_start_date + 1,
          end_date: subject_end_date - 1
        },
        expectation: false
      },
      {
        name: "returns false when the other absence covers the subject",
        other: {
          start_date: subject_start_date - 1,
          end_date: subject_end_date + 1
        },
        expectation: false
      }
    ].each { |test_case|
      it test_case[:name] do
        other = Absence.new(
          type: :holiday,
          start_date: test_case[:other][:start_date],
          end_date: test_case[:other][:end_date],
          start_meridiem: test_case[:other][:start_meridiem] || :am,
          end_meridiem: test_case[:other][:end_meridiem] || :pm
        )
        absence = Absence.new(
          type: :holiday,
          start_date: subject_start_date,
          end_date: subject_end_date,
          start_meridiem: test_case.fetch(:subject, {})[:start_meridiem] || :am,
          end_meridiem: test_case.fetch(:subject, {})[:end_meridiem] || :pm
        )

        expect(absence.adjacent_to?(other)).to be(test_case[:expectation])
      end
    }
  end

  describe "#starts_before?" do
    it "returns true when the other absence starts the day after the start of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date + 30
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.starts_before?(other)).to be(true)
    end

    it "returns true when the other absence starts (PM) on the same day as the start (AM) of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date + 30,
        start_meridiem: :pm
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        start_meridiem: :am
      )

      expect(absence.starts_before?(other)).to be(true)
    end

    it "returns false when the other absence starts (AM) on the same day as the start (PM) of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date + 30,
        start_meridiem: :am
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        start_meridiem: :pm
      )

      expect(absence.starts_before?(other)).to be(false)
    end

    it "returns false when the other absence starts the day before the start of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 1,
        end_date: end_date + 30
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.starts_before?(other)).to be(false)
    end
  end

  describe "#ends_after?" do
    it "returns true when the other absence ends the day before the end of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 30,
        end_date: end_date - 1
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.ends_after?(other)).to be(true)
    end

    it "returns true when the other absence ends (AM) on the same day as the end (PM) of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 30,
        end_date: end_date,
        end_meridiem: :am
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        end_meridiem: :pm
      )

      expect(absence.ends_after?(other)).to be(true)
    end

    it "returns false when the other absence ends (PM) on the same day as the end (AM) of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 30,
        end_date: end_date,
        end_meridiem: :pm
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        end_meridiem: :am
      )

      expect(absence.ends_after?(other)).to be(false)
    end

    it "returns false when the other absence ends the day after the end of the subject" do
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 30,
        end_date: end_date + 1
      )
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )

      expect(absence.ends_after?(other)).to be(false)
    end
  end

  describe "#covers?" do
    it "returns true when the subject starts before and ends after the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date - 1
      )

      expect(absence.covers?(other)).to be(true)
    end

    it "returns true when the subject starts before and ends at the same time as the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date
      )

      expect(absence.covers?(other)).to be(true)
    end

    it "returns false when the subject starts before and ends before the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date + 1
      )

      expect(absence.covers?(other)).to be(false)
    end

    it "returns true when the subject starts at the same time as and ends after the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date - 1
      )

      expect(absence.covers?(other)).to be(true)
    end

    it "returns false when the subject starts after and ends after the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 1,
        end_date: end_date - 1
      )

      expect(absence.covers?(other)).to be(false)
    end

    it "returns false when the subject starts after and ends before the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 1,
        end_date: end_date + 1
      )

      expect(absence.covers?(other)).to be(false)
    end
  end

  describe "#overlaps?" do
    it "returns false when the subject starts before and ends after the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 1,
        end_date: end_date + 1
      )

      expect(absence.overlaps?(other)).to be(false)
    end

    it "returns true when the subject starts before and ends before the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date - 1,
        end_date: end_date - 1
      )

      expect(absence.overlaps?(other)).to be(true)
    end

    it "returns true when the subject starts after and ends after the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date + 1
      )

      expect(absence.overlaps?(other)).to be(true)
    end

    it "returns false when the subject starts after and ends before the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = Absence.new(
        type: :holiday,
        start_date: start_date + 1,
        end_date: end_date - 1
      )

      expect(absence.overlaps?(other)).to be(false)
    end
  end

  describe "#mergeable_with?" do
    it "returns false when the subject and other absence are of different types" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { false }

      expect(absence.mergeable_with?(other)).to be(false)
    end

    it "returns true when the subject and other absence are adjacent" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { true }
      allow(absence).to receive(:adjacent_to?).with(other) { true }

      expect(absence.mergeable_with?(other)).to be(true)
    end

    it "returns true when the subject and other absence overlap" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { true }
      allow(absence).to receive(:adjacent_to?).with(other) { false }
      allow(absence).to receive(:overlaps?).with(other) { true }

      expect(absence.mergeable_with?(other)).to be(true)
    end

    it "returns true when the subject covers the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { true }
      allow(absence).to receive(:adjacent_to?).with(other) { false }
      allow(absence).to receive(:overlaps?).with(other) { false }
      allow(absence).to receive(:covers?).with(other) { true }

      expect(absence.mergeable_with?(other)).to be(true)
    end

    it "returns true when the other absence covers the subject" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { true }
      allow(absence).to receive(:adjacent_to?).with(other) { false }
      allow(absence).to receive(:overlaps?).with(other) { false }
      allow(absence).to receive(:covers?).with(other) { false }
      allow(other).to receive(:covers?).with(absence) { true }

      expect(absence.mergeable_with?(other)).to be(true)
    end

    it "returns false when the subject and other absence are not adjacent, overlapping, nor covering each other" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:matches_type?).with(other) { true }
      allow(absence).to receive(:adjacent_to?).with(other) { false }
      allow(absence).to receive(:overlaps?).with(other) { false }
      allow(absence).to receive(:covers?).with(other) { false }
      allow(other).to receive(:covers?).with(absence) { false }

      expect(absence.mergeable_with?(other)).to be(false)
    end
  end

  describe "#merge_with" do
    it "rejects an impossible merge" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:mergeable_with?).with(other) { false }

      expect {
        absence.merge_with(other)
      }.to raise_error("Cannot merge these absences")
    end

    it "returns the subject when it covers the other absence" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:mergeable_with?).with(other) { true }
      allow(absence).to receive(:covers?).with(other) { true }

      expect(absence.merge_with(other)).to be(absence)
    end

    it "returns the other absence when it covers the subject" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date
      )
      other = instance_double(Absence)

      allow(absence).to receive(:mergeable_with?).with(other) { true }
      allow(absence).to receive(:covers?).with(other) { false }
      allow(other).to receive(:covers?).with(absence) { true }

      expect(absence.merge_with(other)).to be(other)
    end

    it "returns a new absence with the earliest start date and matching start meridiem" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        start_meridiem: :pm
      )
      before = Absence.new(
        type: :holiday,
        start_date: start_date - 3,
        end_date: end_date,
        start_meridiem: :am
      )
      after = Absence.new(
        type: :holiday,
        start_date: start_date + 3,
        end_date: end_date,
        start_meridiem: :am
      )

      new_before = absence.merge_with(before)

      expect(new_before.start_date).to eq(start_date - 3)
      expect(new_before.start_meridiem).to eq(:am)

      new_after = absence.merge_with(after)

      expect(new_after.start_date).to eq(start_date)
      expect(new_after.start_meridiem).to eq(:pm)
    end

    it "returns a new absence with the latest end date and matching end meridiem" do
      absence = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date,
        end_meridiem: :am
      )
      before = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date - 3,
        end_meridiem: :pm
      )
      after = Absence.new(
        type: :holiday,
        start_date: start_date,
        end_date: end_date + 3,
        end_meridiem: :pm
      )

      new_before = absence.merge_with(before)

      expect(new_before.end_date).to eq(end_date)
      expect(new_before.end_meridiem).to eq(:am)

      new_after = absence.merge_with(after)

      expect(new_after.end_date).to eq(end_date + 3)
      expect(new_after.end_meridiem).to eq(:pm)
    end
  end
end
