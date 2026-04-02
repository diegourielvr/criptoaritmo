require 'libui'
require 'socket'


socket = TCPSocket.open('127.0.0.1',50000)



UI = LibUI
UI.init


################################################

# ventana pricipal

################################################

window = UI.new_window('Criptograma - Resolvedor', 520, 400, 1)
UI.window_set_margined(window, 1)

box = UI.new_vertical_box
UI.box_set_padded(box, 1)
UI.window_set_child(window, box)


################################################

# GRUPO 1 - PROBLEMA

################################################

group_problema = UI.new_group('Problema Criptoaritmetico')
UI.group_set_margined(group_problema, 1)
UI.box_append(box, group_problema, 0)

prob_box = UI.new_vertical_box
UI.box_set_padded(prob_box, 1)
UI.group_set_child(group_problema, prob_box)

UI.box_append(prob_box, UI.new_label('Escribe tu criptoaritmo:'), 0)

#campo de texto
input = UI.new_entry
UI.box_append(prob_box,input, 0)
UI.entry_set_text(input, '([[D,O,S],[D,O,S],[T,R,E,S]], [S,I,E,T,E]).')


UI.box_append(prob_box, UI.new_label('Restricciones: cada letra = digito unico (0-9), D≠0, T≠0, S≠0'), 0)

################################################

# GRUPO 2 - Accion

################################################
group_accion = UI.new_group('Acción')
UI.group_set_margined(group_accion, 1)
UI.box_append(box, group_accion, 0)

accion_box = UI.new_vertical_box
UI.box_set_padded(accion_box, 1)
UI.group_set_child(group_accion, accion_box)

#boton
button =UI.new_button('Resolver')
UI.box_append(accion_box, button, 0)

#etiqueta de resultado
result_label = UI.new_label('')
UI.box_append(accion_box, result_label, 0)

UI.window_on_closing(window) do
    UI.quit
    0
end

################################################

# GRUPO 3 - Tabla de resultados

################################################
group_resultado = UI.new_group('Resultado')
UI.group_set_margined(group_resultado, 1)
UI.box_append(box, group_resultado, 0)

result_box = UI.new_vertical_box
UI.box_set_padded(result_box, 1)
UI.group_set_child(group_resultado, result_box)

result_label = UI.new_label('Esperando resultado...')
UI.box_append(result_box, result_label, 0)

label_letras = UI.new_label("")
UI.box_append(result_box, label_letras, 0)

separator = UI.new_horizontal_separator
UI.box_append(result_box, separator, 0)

label_valores = UI.new_label("")
UI.box_append(result_box, label_valores, 0)

label_operacion = UI.new_label("")
UI.box_append(result_box, label_operacion, 0)

#evento del boton
UI.button_on_clicked(button) do
    texto = UI.entry_text(input).to_s
    
    socket.puts(texto)
    socket.flush

    resultado = socket.gets
    
    #puts "RESULTADO: #{resultado}"
    
    resultado = resultado.strip

    vars = {}
    resultado.scan(/([A-Z])=(\d)/) do |letra, valor|
      vars[letra] = valor
    end

    if vars.empty?
      UI.label_set_text(result_label, "Error o sin resultado")
    else
      letras = vars.keys.sort

      fila_letras = letras.join('  ')
      fila_valores = letras.map { |l| vars[l] }.join('  ')
      linea = '-' * fila_letras.length

      UI.label_set_text(label_letras, fila_letras)
      UI.label_set_text(label_valores, fila_valores)

      # Convertir texto de entrada a estructura Ruby texto resultado
      begin
        # Extraer listas de letras manualmente lista
        partes = texto.scan(/\[([A-Za-z,\s]+)\]/)

        # Convertir cada grupo a array
        listas = partes.map { |p| p[0].gsub(' ', '').split(',') }


        # Último es resultado
        resultado_letras = listas.pop
        sumandos = listas

        # Convertir letras a número
        convertir = lambda do |lista|
          lista.map { |l| vars[l] }.join.to_i
        end

        # Convertir cada parte
        numeros = sumandos.map { |s| convertir.call(s) }
        resultado_num = convertir.call(resultado_letras)

        texto_operacion = "#{numeros.join(' + ')} = #{resultado_num}"

        operacion_label = UI.new_label("")

        # Mostrar resultado final
        UI.label_set_text(label_operacion, texto_operacion)

      rescue => e
        puts "ERROR: #{e}"
  puts e.backtrace
        UI.label_set_text(result_label, "Error al procesar operación")
    end
  end
end


# Asignar contenido a la ventana
UI.window_set_child(window, box)

# Mostrar ventana
UI.control_show(window)


UI.main
UI.quit
socket.close