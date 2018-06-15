# Creates a structure to replace the (Staff) Directory and kicks off an import of the same
require './models/directory_entry'

class CreateDirectoryEntries < ActiveRecord::Migration[5.1]
  def up
    unless table_exists? :directory_entries
      create_table :directory_entries do |t|
        t.string :surname
        t.string :forename
        t.string :known_as
        t.string :job_title
        t.text :email_addresses, limit: 64.kilobytes
        t.text :phone_numbers, limit: 64.kilobytes
        t.text :addresses, limit: 64.kilobytes
        t.text :workplaces, limit: 64.kilobytes
        t.integer :old_contact_id
        t.timestamps
      end
    end
    execute "TRUNCATE directory_entries;"
    # import data (will be prompted for Aeolus PGSQL password)
    import_data = `echo "SELECT contact_details.contact_id, contact_details.surname, contact_details.forename, contact_details.jobtitle, contact_details.phone1, contact_details.phone2, contact_details.phone3, contact_details.email, contact_details.address1_room add10, stf_address1.address_line1 add11, stf_address1.address_line2 add12, stf_address1.address_line3 add13, stf_address1.address_line4 add14, stf_address1.address_line5 add15, stf_address1.postcode add16, contact_details.address2_room add20, stf_address2.address_line1 add21, stf_address2.address_line2 add22, stf_address2.address_line3 add23, stf_address2.address_line4 add24, stf_address2.address_line5 add25, stf_address2.postcode add26, contact_details.address3_room add30, stf_address3.address_line1 add31, stf_address3.address_line2 add32, stf_address3.address_line3 add33, stf_address3.address_line4 add34, stf_address3.address_line5 add35, stf_address3.postcode add36, stf_workplace1.workplace_name workplace1, stf_workplace2.workplace_name workplace2, stf_workplace3.workplace_name workplace3 FROM contact_details LEFT JOIN stf_postal_addresses AS stf_address1 ON contact_details.address1 = stf_address1.address_id LEFT JOIN stf_postal_addresses AS stf_address2 ON contact_details.address2 = stf_address2.address_id LEFT JOIN stf_postal_addresses AS stf_address3 ON contact_details.address3 = stf_address3.address_id LEFT JOIN workplaces AS stf_workplace1 ON contact_details.workplace1 = stf_workplace1.workplace_id LEFT JOIN workplaces AS stf_workplace2 ON contact_details.workplace2 = stf_workplace2.workplace_id LEFT JOIN workplaces AS stf_workplace3 ON contact_details.workplace3 = stf_workplace3.workplace_id;" | psql -h aeolus.bodleian.ox.ac.uk -p 5432 -A -t ouls stfeditor`
    import_data.split("\n").reject(&:blank?).each do |row|
      puts row
      contact_id, surname, forename, jobtitle, phone1, phone2, phone3, email, add10, add11, add12, add13, add14, add15, add16, add20, add21, add22, add23, add24, add25, add26, add30, add31, add32, add33, add34, add35, add36, workplace1, workplace2, workplace3 = row.split('|')
      known_as = ''
      if forename =~ /\((.*?)\)/
        known_as = $1
        forename = forename.gsub(/ *\(.*?\) */, '')        
      end
      entry = DirectoryEntry.new(surname: surname.gsub(/ *\(.*?\) */, '')  , forename: forename, known_as: known_as, job_title: jobtitle, old_contact_id: contact_id)
      entry.email_addresses = (email || '').strip.split(/[, ]+/).reject(&:blank?)
      entry.phone_numbers = [phone1, phone2, phone3].reject(&:blank?)
      entry.addresses = [
        [add10, add11, add12, add13, add14, add15, add16],
        [add20, add21, add22, add23, add24, add25, add26],
        [add30, add31, add32, add33, add34, add35, add36]
      ].map{|a| a.reject(&:blank?).join("\n") }.reject(&:blank?)
      entry.workplaces = [workplace1, workplace2, workplace3].reject(&:blank?)
      raise entry.errors.full_messages unless entry.save
    end
  end

  def down
    # Drop all tables
    drop_table :directory_entries if table_exists? :directory_entries
  end
end
