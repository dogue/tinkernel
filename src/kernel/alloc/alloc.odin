package alloc

import "base:runtime"
Allocator_Error :: runtime.Allocator_Error
Allocator_Mode :: runtime.Allocator_Mode

Free_List :: struct {
    data: rawptr,
    size: uint,
    used: uint,
    head: ^Free_List_Node,
}

Free_List_Header :: struct {
    size: uint,
    padding: uint,
}

Free_List_Node :: struct {
    next: ^Free_List_Node,
    size: uint,
}

// free_list_allocator_proc :: proc(
//     allocator_data: rawptr,
//     mode: Allocator_Mode,
//     size, alignment: int,
//     old_memory: rawptr,
//     old_size: int,
//     location := #caller_location
// ) -> ([]u8, Allocator_Error) {
//     free_list := (^Free_List)(allocator_data)
//
//     size, alignment := uint(size), uint(alignment)
//     old_size := uint(old_size)
//
//     switch mode {
//     case .Alloc:
//     case .Alloc_Non_Zeroed:
//     case .Free:
//     case .Free_All:
//     case .Resize:
//     case .Resize_Non_Zeroed:
//     case .Query_Info:
//     case .Query_Features:
//     }
//
// }

// free_list_alloc :: proc(
//     free_list: ^Free_List,
//     size, alignment: uint,
//     loc := #caller_location
// ) -> (data: []u8, err: Allocator_Error){
//     assert(alignment & (alignment - 1) == 0, "non power of two alignment", loc)
//
//     size := size
//     if size == 0 {
//         return nil, nil
//     }
//
//     node := free_list.head
//     prev: ^Free_List_Node
//     padding: uint
//
//     for node != nil {
//     }
//
// }

calc_padding_with_header :: proc(ptr, alignment: uintptr, header_size: uint) -> uint {
    assert(alignment & (alignment - 1) == 0)

    modulo := ptr & (alignment - 1)
    padding: uintptr

    if modulo != 0 {
        padding = alignment - modulo
    }

    needed_space := uintptr(header_size)

    if padding < needed_space {
        needed_space -= padding

        if (needed_space & (alignment - 1)) != 0 {
            padding += alignment * (1 + (needed_space / alignment))
        } else {
            padding += alignment * (needed_space / alignment)
        }
    }

    return uint(padding)
}
