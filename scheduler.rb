class Scheduler


  def initialize(options = {})
    @tasks = []
  end

  def addTask(&block, options = {})

    options = {

    }.merge(options)

    @tasks << block
  end

  def checkTasks

  end

  def run(&shouldquit, options = {})
    if(shouldquit.call())
      return
    end


    sleep(60 * 5)
    run(shouldquit)
  end

end
