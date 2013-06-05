# usage:
# Try following on rails console.
#
# Resque.enqueue(TestWorker)
#
# When you run the code above, "self.perform" in this class is called on
# a background process, then it will make "hello.txt" at your homedir.

class TestWorker
  @queue = :default

  def self.perform
    `touch ~/hello.txt`
  end
end
