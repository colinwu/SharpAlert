class String
  def condition
    if (self =~ /^!/)
      return(self.sub(/^!/,''))
    else
      return(self)
    end
  end

  def where (column)
    if (self =~ /^!/)
      return("#{column} not regexp ?")
    else
      return("#{column} regexp ?")
    end
  end
end