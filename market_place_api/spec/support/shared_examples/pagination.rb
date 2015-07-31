shared_examples 'paginated list' do
  it { expect(json_response[:meta][:pagination]).to have_key(:per_page) }
  it { expect(json_response[:meta][:pagination]).to have_key(:total_pages) }
  it { expect(json_response[:meta][:pagination]).to have_key(:total_objects) }
end