def upgrade ta, td, a, d
  a["volume"]["eternus"] = ta["volume"]["eternus"]
  return a, d
end

def downgrade ta, td, a, d
  a["volume"].delete("eternus")
  return a, d
end
