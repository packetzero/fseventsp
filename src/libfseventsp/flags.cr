
@[Flags]
enum EventFlags

  Created       # 0001
  Removed       # 0002
  InodeMeta     # 0004
  Renamed       # 0008
  Modified      # 0010
  Exchange      # 0020
  FinderInfoMod # 0040
  FolderCreate  # 0080
  Perms         # 0100
  XAttrMod      # 0200
  XAttrDel      # 0400
  Bx0800        # 0800
  Bx1000        # 1000
  Bx2000        # 2000
  ItemCloned    # 4000
  Bx8000        # 8000

  Bx10000       # 0001 0000
  Bx20000       # 0002 0000
  Bx40000       # 0004 0000
  Bx00080000    # 0008 0000
  HardLink      # 0010 0000
  Bx00200000    # 0020 0000
  SymLink       # 0040 0000
  File          # 0080 0000
  Folder        # 0100 0000
  Mount         # 0200 0000
  Unmount       # 0400 0000

end

MASK_ONLY_TYPE = (EventFlags::File | EventFlags::Folder).to_i
MASK_WITHOUT_TYPE = ~MASK_ONLY_TYPE
