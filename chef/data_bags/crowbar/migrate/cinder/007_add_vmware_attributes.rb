def upgrade ta, td, a, d
  a['vmware'] = ta['vmware']
  return a, d
end

def downgrade ta, td, a, d
  a.delete('vmware')
  return a, d
end
