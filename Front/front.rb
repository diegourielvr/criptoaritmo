require 'libui'

UI = LibUI
UI.init

#ventana pricipal
window = UI.new_window('Criptoaritmo', 500, 200, 1)

#contenedor vertical
box  =UI.new_vertical_box
UI.box_set_padded(box, 1)

#campo de texto
input = UI.new_entry
UI.entry_set_text(input, 'Escribe el criptograma (ejemplo: SEND + MORE)')

#boton
button =UI.new_button('Resolver')

#etiqueta de resultado
result_label = UI.new_label('Resultado: #{texto}')

UI.window_on_closing(window) do
    UI.quit
    0
end

#evento del boton
UI.button_on_clicked(button) do
    texto = UI.entry_text(input)

    #Poner la logica aqui.

    UI.label_set_text(result_label, resultado)
    #UI.msg_box(window,'Mensaje','Funciona')
end
# Agregar elementos al contenedor
UI.box_append(box, input, 0)
UI.box_append(box, button, 0)
UI.box_append(box, result_label, 0)

# Asignar contenido a la ventana
UI.window_set_child(window, box)

# Mostrar ventana
UI.control_show(window)


UI.main
UI.quit