module ExperimentsHelper
  def mint_server_up?
    MintServerStatus.server_up?
  end
end
