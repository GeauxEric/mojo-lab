alias type = DType.float32
from random import rand


struct Matrix[rows: Int, cols: Int]:
    var data: DTypePointer[type]

    # Initialize zeroeing all values
    fn __init__(inout self):
        self.data = DTypePointer[type].alloc(rows * cols)
        memset_zero(self.data, rows * cols)

    # Initialize taking a pointer, don't set any elements
    fn __init__(inout self, data: DTypePointer[type]):
        self.data = data

    fn __copyinit__(inout self, existing: Self):
        var n = rows * cols
        self.data = DTypePointer[type].alloc(n)
        memcpy[rows * cols](self.data, existing.data)

    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data
        # destructor of `existing` is disabled,
        # don't worry the resource is released twice

    fn __del__(owned self):
        self.data.free()

    ## Initialize with random values
    @staticmethod
    fn rand() -> Self:
        var data = DTypePointer[type].alloc(rows * cols)
        rand(data, rows * cols)
        return Self(data)

    fn __getitem__(self, y: Int, x: Int) -> Scalar[type]:
        return self.load[1](y, x)

    fn __setitem__(inout self, y: Int, x: Int, val: Scalar[type]):
        self.store[1](y, x, val)

    fn load[nelts: Int](self, y: Int, x: Int) -> SIMD[type, nelts]:
        return self.data.load[width=nelts](y * self.cols + x)

    fn store[nelts: Int](self, y: Int, x: Int, val: SIMD[type, nelts]):
        return self.data.store[width=nelts](y * self.cols + x, val)


def main():
    var m0 = Matrix[1, 1].rand()
    print(m0[0, 0])
    var m1 = m0^
    print(m1[0, 0])
