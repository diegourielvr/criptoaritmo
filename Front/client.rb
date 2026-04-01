require 'socket'

socket = TCPSocket.open('127.0.0.1',50000)

l = ""
puts("Dame una lista y un elemento en líneas separadas")
while l!="fin.\n"
  print("Lista:")
  l = gets  
  socket.write(l)
  print("Elemento:")
  l = gets  
  socket.write(l)
  ln = socket.recv(100)
  puts ("El elemento #{ln} esta en la lista")
end
# socket.puts("3,[1,2,3,4].\n\r")


# puts ln

socket.close