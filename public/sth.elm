find : Bst -> String -> Maybe String
find tree key =
    case tree of
        Empty _ ->
            Nothing
        Node ( keyHere, valueHere ) leftChild rightChild ->
            if key == keyHere then
                Just valueHere
            else if key < keyHere then
                find leftChild key
            else
                find rightChild key