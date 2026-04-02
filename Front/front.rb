require 'libui'
require 'socket'

UI = LibUI
UI.init

# =========================================================
#  Funcion para comunicarse con el servidor Prolog
# =========================================================

def consultar_prolog(comando)
  socket = TCPSocket.open('127.0.0.1', 50000)
  socket.write("#{comando}.\n")
  respuesta = socket.recv(1024).strip
  socket.write("fin.\n")
  socket.close
  respuesta
rescue Errno::ECONNREFUSED
  "ERROR: No se pudo conectar al servidor Prolog"
rescue => e
  "ERROR: #{e.message}"
end

def parsear_respuesta(respuesta)
  vars = {}
  respuesta.scan(/(\w)=(\d)/) { |k, v| vars[k] = v }
  vars
end

# =========================================================
#  Ventana principal
# =========================================================

window = UI.new_window('Criptograma - Resolvedor', 520, 400, 1)
UI.window_set_margined(window, 1)

main_box = UI.new_vertical_box
UI.box_set_padded(main_box, 1)
UI.window_set_child(window, main_box)

# =========================================================
#  Grupo 1 — Problema
# =========================================================

group_problema = UI.new_group('Problema Criptoaritmetico')
UI.group_set_margined(group_problema, 1)
UI.box_append(main_box, group_problema, 0)

prob_box = UI.new_vertical_box
UI.box_set_padded(prob_box, 1)
UI.group_set_child(group_problema, prob_box)

UI.box_append(prob_box, UI.new_label('Encuentra los digitos que satisfacen la ecuacion:'), 0)
UI.box_append(prob_box, UI.new_label(''), 0)
UI.box_append(prob_box, UI.new_label('        D O S'), 0)
UI.box_append(prob_box, UI.new_label('      + D O S'), 0)
UI.box_append(prob_box, UI.new_label('      + D O S'), 0)
UI.box_append(prob_box, UI.new_label('     -------'), 0)
UI.box_append(prob_box, UI.new_label('    S I E T E'), 0)
UI.box_append(prob_box, UI.new_label(''), 0)
UI.box_append(prob_box, UI.new_label('Restricciones: cada letra = digito unico (0-9), D<>0, T<>0, S<>0'), 0)

# =========================================================
#  Grupo 2 — Accion
# =========================================================

group_accion = UI.new_group('Resolver')
UI.group_set_margined(group_accion, 1)
UI.box_append(main_box, group_accion, 0)

accion_box = UI.new_vertical_box
UI.box_set_padded(accion_box, 1)
UI.group_set_child(group_accion, accion_box)

status_label = UI.new_label('Presiona el boton para consultar al servidor Prolog...')
UI.box_append(accion_box, status_label, 0)
UI.box_append(accion_box, UI.new_label(''), 0)

btn = UI.new_button('Resolver con Prolog')
UI.box_append(accion_box, btn, 0)

# =========================================================
#  Grupo 3 — Tabla de resultados
# =========================================================

group_result = UI.new_group('Asignacion de Valores')
UI.group_set_margined(group_result, 1)
UI.box_append(main_box, group_result, 1)

result_box = UI.new_vertical_box
UI.box_set_padded(result_box, 1)
UI.group_set_child(group_result, result_box)

letras_row = UI.new_horizontal_box
UI.box_set_padded(letras_row, 1)
UI.box_append(result_box, letras_row, 0)

letras = %w[D O S T R E I]
letras.each do |l|
  UI.box_append(letras_row, UI.new_label("  #{l}  "), 1)
end

UI.box_append(result_box, UI.new_horizontal_separator, 0)

valor_row = UI.new_horizontal_box
UI.box_set_padded(valor_row, 1)
UI.box_append(result_box, valor_row, 0)

valor_labels = {}
letras.each do |l|
  lbl = UI.new_label('  ?  ')
  UI.box_append(valor_row, lbl, 1)
  valor_labels[l] = lbl
end

UI.box_append(result_box, UI.new_label(''), 0)

ecuacion_label = UI.new_label('Resultado: ---')
UI.box_append(result_box, ecuacion_label, 0)

# =========================================================
#  Evento del boton
# =========================================================

UI.button_on_clicked(btn) do
  UI.label_set_text(status_label, 'Consultando servidor Prolog...')
  UI.label_set_text(ecuacion_label, 'Calculando...')
  letras.each { |l| UI.label_set_text(valor_labels[l], '  ?  ') }

  respuesta = consultar_prolog('resolver')
  vars = parsear_respuesta(respuesta)

  if respuesta.start_with?('ERROR') || vars.empty?
    UI.label_set_text(status_label, "Error: #{respuesta}")
    UI.label_set_text(ecuacion_label, 'Sin solucion')
  else
    d, o, s = vars['D'], vars['O'], vars['S']
    t, r, e, i = vars['T'], vars['R'], vars['E'], vars['I']
    dos   = "#{d}#{o}#{s}".to_i
    siete = "#{s}#{i}#{e}#{t}#{e}".to_i

    vals = { 'D' => d, 'O' => o, 'S' => s, 'T' => t, 'R' => r, 'E' => e, 'I' => i }
    vals.each { |letra, val| UI.label_set_text(valor_labels[letra], "  #{val}  ") }

    UI.label_set_text(ecuacion_label, "OK  #{dos} + #{dos} + #{dos} = #{siete}")
    UI.label_set_text(status_label, 'Solucion encontrada exitosamente')
  end
end

# =========================================================
#  Cerrar
# =========================================================

UI.window_on_closing(window) do
  UI.quit
  0
end

UI.control_show(window)
UI.main
UI.quit