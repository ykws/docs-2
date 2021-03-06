/*
 * frame.c
 * @copyright (c) 2007-2010, Tohoku University.
 * @author UENO Katsuhiro
 */

#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <setjmp.h>
#include "smlsharp.h"
#include "object.h"
#include "frame.h"
#include "objspace.h"
#include "control.h"

struct sml_control {
	void *frame_stack_top;
	void *frame_stack_bottom;
	sml_obstack_t *tmp_root;      /* temporary root slots of GC. */
};

static struct sml_control *global_control;

static void control_finalize();

SML_PRIMITIVE void
sml_control_start(void *frame_pointer)
{
	if (global_control == NULL) {
		global_control = xmalloc(sizeof(struct sml_control));
		global_control->frame_stack_top = frame_pointer;
		global_control->frame_stack_bottom = frame_pointer;
		global_control->tmp_root = NULL;
		DBG(("START NEW THREAD : %p", pthread_self()));
	} else {
		FRAME_HEADER(frame_pointer) |= FRAME_FLAG_SKIP;
		FRAME_EXTRA(frame_pointer) =
			(uintptr_t)global_control->frame_stack_top;
		global_control->frame_stack_top = frame_pointer;
	}

}

static void
control_finalize()
{
	if (global_control == NULL)
		return;
	sml_obstack_free(&global_control->tmp_root, NULL);
	free(global_control);
	global_control = NULL;
}

SML_PRIMITIVE void
sml_control_finish(void *frame_pointer)
{
	if (global_control->frame_stack_bottom == frame_pointer) {
		DBG(("FINISH THREAD : %p", pthread_self()));
		control_finalize();
	} else {
		ASSERT(FRAME_HEADER(frame_pointer) & FRAME_FLAG_SKIP);
		global_control->frame_stack_top = (void*)FRAME_EXTRA(frame_pointer);
	}
}

/*
 * prepares new "num_slots" pointer slots which are part of root set of garbage
 * collection, and returns the address of array of the new pointer slots.
 * These pointer slots are available until sml_pop_tmp_rootset() is called.
 * Returned address is only available in the same thread.
 */
void **
sml_push_tmp_rootset(size_t num_slots)
{
	void **ret;
	unsigned int i;

	ret = sml_obstack_alloc(&global_control->tmp_root, sizeof(void*) * num_slots);
	for (i = 0; i < num_slots; i++)
		ret[i] = NULL;
	return ret;
}

/*
 * releases last pointer slots allocated by sml_push_tmp_rootset()
 * in the same thread.
 */
void
sml_pop_tmp_rootset(void **slots)
{
	sml_obstack_free(&global_control->tmp_root, slots);
}

SML_PRIMITIVE void
sml_save_frame_pointer(void *p)
{
	global_control->frame_stack_top = p;
}

void *
sml_load_frame_pointer()
{
	return global_control->frame_stack_top;
}

static void
frame_enum_ptr(void *frame_info, void (*trace)(void **))
{
	void **boxed;
	unsigned int *sizes, *bitmaps, num_generics, num_boxed;
	unsigned int i, j, num_slots;
	ptrdiff_t offset;
	char *generic;

	num_boxed = FRAME_NUM_BOXED(frame_info);
	num_generics = FRAME_NUM_GENERIC(frame_info);
	boxed = FRAME_BOXED_PART(frame_info);

	for (i = 0; i < num_boxed; i++) {
		if (*boxed)
			trace(boxed);
		boxed++;
	}

	offset = (char*)boxed - (char*)frame_info;
	offset = ALIGNSIZE(offset, sizeof(unsigned int));
	sizes = (unsigned int *)(frame_info + offset);
	bitmaps = sizes + num_generics;
	generic = frame_info;

	for (i = 0; i < num_generics; i++) {
		num_slots = sizes[i];
		if (BITMAP_BIT(bitmaps, i) == TAG_UNBOXED) {
			generic -= num_slots * SIZEOF_GENERIC;
		} else {
			for (j = 0; j < num_slots; j++) {
				generic -= SIZEOF_GENERIC;
				trace((void**)generic);
			}
		}
	}
}

static void
stack_enum_ptr(void (*trace)(void **),
	       void *frame_stack_top, void *frame_stack_bottom)
{
	void *fp = frame_stack_top;
	uintptr_t header;
	intptr_t offset;

	for (;;) {
		header = FRAME_HEADER(fp);
		FRAME_HEADER(fp) = header | FRAME_FLAG_VISITED;

		offset = FRAME_INFO_OFFSET(header);
		if (offset != 0)
			frame_enum_ptr((char*)fp + offset, trace);

		/* When MINOR tracing, we need to trace not only unvisited
		 * frames but also the first frame of visited frames since
		 * the first frame may be modified by ML code from the
		 * previous frame tracing.
		 */

		if (fp == frame_stack_bottom)
			break;

		if (header & FRAME_FLAG_SKIP)
			fp = (void*)FRAME_EXTRA(fp);
		else
			fp = FRAME_NEXT(fp);
	}

	DBG(("frame end"));
}

struct enum_ptr_cls {
	void (*trace)(void **);
};

static void
tmp_root_enum_ptr(void *start, void *end, void *data)
{
	const struct enum_ptr_cls *cls = data;
	void (*trace)(void **) = cls->trace;
	void **i;
	for (i = start; i < (void**)end; i++)
		trace(i);
}

void
sml_control_enum_ptr(void (*trace)(void **))
{
	struct enum_ptr_cls arg = {trace};

	if(global_control) {
		stack_enum_ptr(trace, global_control->frame_stack_top,
			       global_control->frame_stack_bottom);
		sml_obstack_enum_chunk(global_control->tmp_root,
				       tmp_root_enum_ptr, &arg);
	}
}

/* for debug */
void
sml_control_dump()
{
	if(global_control) {
		sml_notice("%p: stack=(%p, %p)"
			   , global_control,
			   global_control->frame_stack_top,
			   global_control->frame_stack_bottom
			   );
	}
}
