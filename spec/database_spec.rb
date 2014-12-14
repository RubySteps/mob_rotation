require_relative 'spec_helper'

describe MobRotation::Database do
  let(:temp_rotation_db) { '/tmp/rotation_test.txt' }

  it 'formats the mobster, maintaining original name and email data' do
    database = MobRotation::Database.new(temp_rotation_db)

    name, email = "   David    ", " david.is.great@i.am.fab.com      "
    formatted_name_and_email = database.format_mobster(name,email)

    expect(formatted_name_and_email).to eq('   David     < david.is.great@i.am.fab.com      >')
  end

end
