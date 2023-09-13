import limine;

__gshared limine.FramebufferRequest framebufferReq = {
    id: mixin(limine.FramebufferRequestID!()),
    revision: 0
};

private void hcf() {
    asm { "cli"; }
    for (;;) {
        asm { "hlt"; }
    }
}

extern (C) void _start() {
    if (framebufferReq.response == null
     || framebufferReq.response.framebufferCount < 1) {
        hcf();
    }

    limine.Framebuffer* framebuffer = framebufferReq.response.framebuffers[0];

    foreach (ulong i; 0..100) {
        uint* fbPtr = cast(uint*)framebuffer.address;
        fbPtr[i * (framebuffer.pitch / 4) + i] = 0xffffff;
    }

    hcf();
}
