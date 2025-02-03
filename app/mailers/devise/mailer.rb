def lock(record, reason, opts={})
  @reason = reason
  devise_mail(record, :lock, opts)
end 

def unlock(record, reason, opts={})
  @reason = reason
  devise_mail(record, :unlock, opts)
end