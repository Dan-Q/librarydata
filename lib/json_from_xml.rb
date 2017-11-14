module JsonFromXml
  def as_json(options = nil)
    Hash::from_xml(to_xml)
  end
end
