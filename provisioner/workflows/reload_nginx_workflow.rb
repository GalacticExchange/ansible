class ReloadNginxWorkflow < Gush::Workflow

  def configure(time_issued=0)

    run NginxReloadJob, params: {time_issued: time_issued}

  end

end
