class FreeVoucher < Voucher
  def apply(job)
    job.errors.add(:base, "Voucher is not enabled") unless enable?
  end
end
