def upgrade ta, td, a, d
  tmpdict = a[:volume]
  a[:volume] = {}
  a[:volume][:default] = tmpdict
  return a, d
end

def downgrade ta, td, a, d
  tmpdict = a[:volume][:default]
  a[:volume] = tmpdict
  return a, d
end
