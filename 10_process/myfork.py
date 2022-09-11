import os, time
import sys
import signal

def receiveSignal(signalNumber, frame):
    print('Перехвачен сигнал:', signalNumber)
    if signalNumber == 2:
      print('Выходим по Ctrl+C:')
      sys.exit(0)
    if signalNumber == 15:
      print('Выходим по SIGTERM')
      sys.exit(0)
    return


if __name__ == '__main__':
    # Регистрируемся на сигналы
    signal.signal(signal.SIGHUP, receiveSignal)
    signal.signal(signal.SIGINT, receiveSignal)
    signal.signal(signal.SIGQUIT, receiveSignal)
    signal.signal(signal.SIGILL, receiveSignal)
    signal.signal(signal.SIGTRAP, receiveSignal)
    signal.signal(signal.SIGABRT, receiveSignal)
    signal.signal(signal.SIGBUS, receiveSignal)
    signal.signal(signal.SIGFPE, receiveSignal)
    signal.signal(signal.SIGUSR1, receiveSignal)
    signal.signal(signal.SIGSEGV, receiveSignal)
    signal.signal(signal.SIGUSR2, receiveSignal)
    signal.signal(signal.SIGPIPE, receiveSignal)
    signal.signal(signal.SIGALRM, receiveSignal)
    signal.signal(signal.SIGTERM, receiveSignal)

print('Hello! I am an example')
pid = os.fork()
print('pid of my child is %s' % pid)
if pid == 0:
    print('I am a child. Im going to sleep')
    for i in range(1,40):
      print('mrrrrr')
      a = 2**i
      print(a)
      pidChild = os.fork()
      if pidChild == 0:
            print('my name is %s' % a)
            sys.exit(0)
      else:
            print("my child pid is %s" % pidChild)
      time.sleep(1)
    print('Bye')
    sys.exit(0)

else:
    for i in range(1,200):
      print('HHHrrrrr')

      time.sleep(1)
      pid, status = os.waitpid(pid, 0)
      print(3**i)
    print('I am the parent')

#pid, status = os.waitpid(pid, 0)
#print "wait returned, pid = %d, status = %d" % (pid, status)

