require 'spec_helper'

RSpec.describe DbSchema::Definitions::Table do
  subject do
    DbSchema::Definitions::Table.new(
      :users,
      fields: [
        DbSchema::Definitions::Field::Integer.new(:id, primary_key: true),
        DbSchema::Definitions::Field::Varchar.new(:phone),
        DbSchema::Definitions::Field::Varchar.new(:first_name),
        DbSchema::Definitions::Field::Varchar.new(:last_name),
        DbSchema::Definitions::Field::Integer.new(:city_id, null: false)
      ],
      indexes: [
        DbSchema::Definitions::Index.new(
          name: :users_phone_index,
          columns: [
            DbSchema::Definitions::Index::TableField.new(:phone)
          ],
          unique: true
        ),
        DbSchema::Definitions::Index.new(
          name: :users_name_index,
          columns: [
            DbSchema::Definitions::Index::TableField.new(:first_name),
            DbSchema::Definitions::Index::TableField.new(:last_name)
          ]
        )
      ],
      checks: [
        DbSchema::Definitions::CheckConstraint.new(
          name: :name_present,
          condition: 'first_name IS NOT NULL OR last_name IS NOT NULL'
        )
      ],
      foreign_keys: [
        DbSchema::Definitions::ForeignKey.new(name: :user_city_id_fkey, fields: [:city_id], table: :cities)
      ]
    )
  end

  describe '#field' do
    context 'with a name of an existing field' do
      it 'returns the field definition' do
        expect(subject.field(:first_name)).to eq(subject.fields[2])
      end
    end

    context 'with an unknown field name' do
      it 'returns a NullField' do
        expect(subject.field(:email)).to be_a(DbSchema::Definitions::NullField)
      end
    end
  end

  describe '#has_field?' do
    context 'with a name of an existing field' do
      it 'returns true' do
        expect(subject).to have_field(:first_name)
      end
    end

    context 'with an unknown field name' do
      it 'returns false' do
        expect(subject).not_to have_field(:email)
      end
    end
  end

  describe '#index' do
    context 'with a name of an existing index' do
      it 'returns the index definition' do
        expect(subject.index(:users_name_index)).to eq(subject.indexes.last)
      end
    end

    context 'with an unknown index name' do
      it 'returns a NullIndex' do
        expect(subject.index(:users_email_index)).to be_a(DbSchema::Definitions::NullIndex)
      end
    end
  end

  describe '#has_index?' do
    context 'with a name of an existing index' do
      it 'returns true' do
        expect(subject).to have_index(:users_name_index)
      end
    end

    context 'with an unknown index name' do
      it 'returns false' do
        expect(subject).not_to have_index(:users_email_index)
      end
    end
  end

  describe '#has_index_on?' do
    context 'with names of indexed fields' do
      it 'returns true' do
        expect(subject).to have_index_on(:first_name, :last_name)
      end
    end

    context 'with names of non-indexed fields' do
      it 'returns false' do
        expect(subject).not_to have_index_on(:first_name)
      end
    end
  end

  describe '#has_unique_index_on?' do
    context 'with names of fields in a unique index' do
      it 'returns true' do
        expect(subject).to have_unique_index_on(:phone)
      end
    end

    context "with names of fields that don't belong to a unique index" do
      it 'returns false' do
        expect(subject).not_to have_unique_index_on(:last_name)
      end
    end
  end

  describe '#check' do
    context 'with a name of an existing check constraint' do
      it 'returns a check constraint definition' do
        expect(subject.check(:name_present)).to eq(subject.checks.first)
      end
    end

    context 'with an unknown check constraint name' do
      it 'returns a NullCheckConstraint' do
        expect(subject.check(:phone_valid)).to be_a(DbSchema::Definitions::NullCheckConstraint)
      end
    end
  end

  describe '#has_check?' do
    context 'with a name of an existing check constraint' do
      it 'returns true' do
        expect(subject).to have_check(:name_present)
      end
    end

    context 'with an unknown check constraint name' do
      it 'returns false' do
        expect(subject).not_to have_check(:phone_valid)
      end
    end
  end

  describe '#foreign_key' do
    context 'with a name of an existing foreign key' do
      it 'returns a foreign key definition' do
        expect(subject.foreign_key(:user_city_id_fkey)).to eq(subject.foreign_keys.first)
      end
    end

    context 'with an unknown foreign key name' do
      it 'returns a NullForeignKey' do
        expect(subject.foreign_key(:user_country_id_fkey)).to be_a(DbSchema::Definitions::NullForeignKey)
      end
    end
  end

  describe '#has_foreign_key?' do
    context 'with a name of an existing foreign key' do
      it 'returns true' do
        expect(subject).to have_foreign_key(:user_city_id_fkey)
      end
    end

    context 'with an unknown foreign key name' do
      it 'returns false' do
        expect(subject).not_to have_foreign_key(:user_country_id_fkey)
      end
    end
  end

  describe '#has_foreign_key_to?' do
    context 'with a table name referenced by a foreign key' do
      it 'returns true' do
        expect(subject).to have_foreign_key_to(:cities)
      end
    end

    context 'with a table name not referenced by a foreign key' do
      it 'returns false' do
        expect(subject).not_to have_foreign_key_to(:countries)
      end
    end
  end
end
