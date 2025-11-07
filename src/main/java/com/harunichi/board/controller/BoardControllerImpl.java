package com.harunichi.board.controller;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import com.harunichi.board.service.BoardService;
import com.harunichi.board.vo.BoardLikeVo;
import com.harunichi.board.vo.BoardVo;
import com.harunichi.board.vo.ReplyVo;
import com.harunichi.member.service.MemberService;
import com.harunichi.member.vo.MemberVo;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller("boardController")
@RequestMapping("/board")
public class BoardControllerImpl implements BoardController {

    @Autowired
    private com.harunichi.common.storage.AzureBlobStorageService blobService;

    @Autowired
    private BoardService boardService;

    @Autowired
    private MemberService memberService;

    /** 이미지 여러 개 업로드 → Blob URL 목록 반환 */
    private List<String> uploadFilesToBlob(List<MultipartFile> imageFiles) throws Exception {
        List<String> urls = new ArrayList<>();
        if (imageFiles == null || imageFiles.isEmpty()) return urls;
        for (MultipartFile mf : imageFiles) {
            if (mf == null || mf.isEmpty()) continue;
            if (mf.getContentType() == null || !mf.getContentType().startsWith("image/")) continue;
            var r = blobService.upload("board", mf);
            urls.add(r.url);
        }
        return urls;
    }

    /** Blob URL(또는 objectPath) 존재 시 삭제 */
    private void deleteBlobIfExists(String urlOrPath) {
        if (urlOrPath == null || urlOrPath.isEmpty()) return;
        String path = urlOrPath.startsWith("http")
                ? blobService.toObjectPath(urlOrPath)
                : urlOrPath;
        try { blobService.deleteByObjectPath(path); } catch (Exception ignore) {}
    }

    /** 게시글 목록 */
    @Override
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public ModelAndView boardList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelAndView mav = new ModelAndView("/board/list");
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");

            List<BoardVo> boardList = boardService.selectBoardList();
            Map<String, MemberVo> memberCache = new HashMap<>();

            for (BoardVo board : boardList) {
                int boardId = board.getBoardId();
                board.setBoardRe(boardService.getReplyCountByBoardId(boardId));
                board.setBoardLike(boardService.getBoardLikeCount(boardId));

                if (loginUser != null) {
                    BoardLikeVo likeVo = new BoardLikeVo();
                    likeVo.setBoardLikeUser(loginUser.getId());
                    likeVo.setBoardLikePost(boardId);
                    boolean isLiked = boardService.checkBoardLikeStatus(likeVo);
                    mav.getModel().computeIfAbsent("likedPosts", k -> new HashMap<Integer, Boolean>());
                    @SuppressWarnings("unchecked")
                    Map<Integer, Boolean> likedPosts = (Map<Integer, Boolean>) mav.getModel().get("likedPosts");
                    likedPosts.put(boardId, isLiked);
                }

                String writerId = board.getBoardWriterId();
                if (writerId != null && !writerId.isEmpty()) {
                    MemberVo info = memberCache.get(writerId);
                    if (info == null) {
                        info = memberService.selectMemberById(writerId);
                        if (info != null) memberCache.put(writerId, info);
                    }
                    if (info != null) board.setBoardWriterImg(info.getProfileImg());
                }

                if (board.getBoardCont() != null) {
                    board.setBoardCont(board.getBoardCont().replaceAll("(\r\n|\r|\n)", "<br />"));
                }
            }

            mav.addObject("top5List", boardService.getTop5BoardsByViews());
            mav.addObject("boardList", boardList);
        } catch (Exception e) {
            log.error("게시글 목록 로딩 오류", e);
            mav.addObject("msg", "게시글 목록을 불러오는 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /** 글쓰기 폼 */
    @RequestMapping(value = "/postForm", method = RequestMethod.GET)
    public String boardForm() { return "/board/postForm"; }

    /** 게시글 등록 (이미지 Blob 저장) */
    @Override
    @RequestMapping(value = "/post", method = RequestMethod.POST)
    public ModelAndView boardPost(HttpServletRequest request,
                                  HttpServletResponse response,
                                  @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {
        ModelAndView mav = new ModelAndView();
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");
            if (loginUser == null) {
                mav.addObject("msg", "로그인이 필요합니다.");
                mav.setViewName("redirect:/member/loginpage.do");
                return mav;
            }

            String boardCont = request.getParameter("boardCont");
            String boardCate = request.getParameter("boardCate");

            BoardVo boardVo = new BoardVo();
            boardVo.setBoardWriter(loginUser.getNick());
            boardVo.setBoardWriterId(loginUser.getId());
            boardVo.setBoardWriterImg(loginUser.getProfileImg());
            boardVo.setBoardCate(boardCate);
            boardVo.setBoardCont(boardCont);
            boardVo.setBoardDate(new Timestamp(System.currentTimeMillis()));

            List<String> urls = uploadFilesToBlob(imageFiles);
            if (urls.size() > 0) boardVo.setBoardImg1(urls.get(0));
            if (urls.size() > 1) boardVo.setBoardImg2(urls.get(1));
            if (urls.size() > 2) boardVo.setBoardImg3(urls.get(2));
            if (urls.size() > 3) boardVo.setBoardImg4(urls.get(3));

            boardService.insertBoard(boardVo);
            mav.setViewName("redirect:/board/list");
        } catch (Exception e) {
            log.error("게시글 등록 오류", e);
            mav.addObject("msg", "게시글 등록 중 오류가 발생했습니다.");
            mav.setViewName("/board/errorPage");
        }
        return mav;
    }

    /** 게시글 상세 */
    @Override
    @RequestMapping(value = "/view", method = RequestMethod.GET)
    public ModelAndView viewBoard(HttpServletRequest request,
                                  HttpServletResponse response,
                                  @RequestParam("boardId") int boardId) throws Exception {
        ModelAndView mav = new ModelAndView("/board/view");
        try {
            BoardVo boardVo = boardService.getBoardById(boardId);
            if (boardVo == null) {
                mav.setViewName("redirect:/board/list");
                mav.addObject("msg", "notfound");
                return mav;
            }

            boardVo.setBoardRe(boardService.getReplyCountByBoardId(boardId));
            List<ReplyVo> replyList = boardService.getRepliesByBoardId(boardId);

            Map<String, MemberVo> memberCache = new HashMap<>();
            for (ReplyVo reply : replyList) {
                String replyWriterId = reply.getReplyWriterId();
                if (replyWriterId != null && !replyWriterId.isEmpty()) {
                    MemberVo memberInfo = memberCache.get(replyWriterId);
                    if (memberInfo == null) {
                        memberInfo = memberService.selectMemberById(replyWriterId);
                        if (memberInfo != null) memberCache.put(replyWriterId, memberInfo);
                    }
                    if (memberInfo != null) reply.setReplyWriterImg(memberInfo.getProfileImg());
                }
            }
            mav.addObject("replyList", replyList);

            String writerId = boardVo.getBoardWriterId();
            if (writerId != null && !writerId.isEmpty()) {
                MemberVo writerInfo = memberService.selectMemberById(writerId);
                if (writerInfo != null) boardVo.setBoardWriterImg(writerInfo.getProfileImg());
            }

            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");

            if (boardVo.getBoardCont() != null) {
                boardVo.setBoardCont(boardVo.getBoardCont().replaceAll("(\r\n|\r|\n)", "<br />"));
            }

            if (loginUser != null) {
                BoardLikeVo likeVo = new BoardLikeVo();
                likeVo.setBoardLikeUser(loginUser.getId());
                likeVo.setBoardLikePost(boardId);
                mav.addObject("isLiked", boardService.checkBoardLikeStatus(likeVo));
            }

            mav.addObject("board", boardVo);
            mav.addObject("likeCount", boardService.getBoardLikeCount(boardId));
            mav.addObject("top5List", boardService.getTop5BoardsByViews());
        } catch (Exception e) {
            log.error("게시글 상세 조회 오류 boardId: {}", boardId, e);
            mav.addObject("msg", "게시글 상세 조회 중 오류가 발생했습니다.");
            mav.setViewName("/board/errorPage");
        }
        return mav;
    }

    /** 수정 폼 */
    @Override
    @RequestMapping(value = "/editForm", method = RequestMethod.GET)
    public ModelAndView editBoardForm(HttpServletRequest request,
                                      HttpServletResponse response,
                                      @RequestParam("boardId") int boardId) throws Exception {
        ModelAndView mav = new ModelAndView("/board/editForm");
        try {
            BoardVo boardVo = boardService.getBoardByIdWithoutIncrement(boardId);
            if (boardVo == null) {
                mav.addObject("msg", "게시글을 찾을 수 없습니다.");
                mav.setViewName("redirect:/board/list");
                return mav;
            }
            mav.addObject("board", boardVo);
        } catch (Exception e) {
            log.error("수정 폼 로딩 오류 boardId: {}", boardId, e);
            mav.addObject("msg", "게시글 수정 폼 로딩 중 오류가 발생했습니다.");
            mav.setViewName("redirect:/board/list");
        }
        return mav;
    }


    /** 게시글 수정 (Blob 이미지 정리 포함) */
    @Override
    @RequestMapping(value = "/update", method = RequestMethod.POST)
    public ModelAndView updateBoard(HttpServletRequest request,
                                    HttpServletResponse response,
                                    @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles,
                                    @RequestParam(value = "deleteIndices", required = false) List<Integer> deleteIndices) {
        ModelAndView mav = new ModelAndView();
        try {
            int boardId = Integer.parseInt(request.getParameter("boardId"));
            String boardCont = request.getParameter("boardCont");
            String boardCate = request.getParameter("boardCate");

            BoardVo existing = boardService.getBoardByIdWithoutIncrement(boardId);
            if (existing == null) {
                mav.addObject("msg", "수정하려는 게시글을 찾을 수 없습니다.");
                mav.setViewName("redirect:/board/list");
                return mav;
            }

            List<String> current = new ArrayList<>();
            if (existing.getBoardImg1() != null) current.add(existing.getBoardImg1());
            if (existing.getBoardImg2() != null) current.add(existing.getBoardImg2());
            if (existing.getBoardImg3() != null) current.add(existing.getBoardImg3());
            if (existing.getBoardImg4() != null) current.add(existing.getBoardImg4());

            // 삭제 요청된 기존 이미지 URL 수집
            List<String> toDelete = new ArrayList<>();
            if (deleteIndices != null) {
                for (Integer idx : deleteIndices) {
                    int i = idx - 1;
                    if (i >= 0 && i < current.size() && current.get(i) != null) {
                        toDelete.add(current.get(i));
                        current.set(i, null);
                    }
                }
            }
            // null 제거(빈 칸 밀착)
            List<String> remained = new ArrayList<>();
            for (String u : current) if (u != null) remained.add(u);

            // 새 이미지 업로드
            List<String> uploaded = uploadFilesToBlob(imageFiles);

            // 최종 4개로 구성
            List<String> finalImages = new ArrayList<>(remained);
            for (String u : uploaded) {
                if (finalImages.size() < 4) finalImages.add(u);
                else {
                    // 초과 업로드분은 즉시 정리
                    deleteBlobIfExists(u);
                }
            }

            existing.setBoardCont(boardCont);
            existing.setBoardCate(boardCate);
            existing.setBoardModDate(new Timestamp(System.currentTimeMillis()));
            existing.setBoardImg1(finalImages.size() > 0 ? finalImages.get(0) : null);
            existing.setBoardImg2(finalImages.size() > 1 ? finalImages.get(1) : null);
            existing.setBoardImg3(finalImages.size() > 2 ? finalImages.get(2) : null);
            existing.setBoardImg4(finalImages.size() > 3 ? finalImages.get(3) : null);

            boardService.updateBoard(existing);

            // DB 업데이트 성공 후 Blob 정리
            for (String del : toDelete) deleteBlobIfExists(del);

            mav.setViewName("redirect:/board/view?boardId=" + boardId);
        } catch (Exception e) {
            log.error("게시글 수정 오류", e);
            mav.addObject("msg", "게시글 수정 중 오류가 발생했습니다.");
            mav.setViewName("redirect:/board/list");
        }
        return mav;
    }

    /** 게시글 삭제 (DB → Blob 순서로 정리) */
    @Override
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public ModelAndView deleteBoard(HttpServletRequest request,
                                    HttpServletResponse response,
                                    @RequestParam("boardId") int boardId) throws Exception {
        ModelAndView mav = new ModelAndView();
        try {
            BoardVo target = boardService.getBoardByIdWithoutIncrement(boardId);
            if (target == null) {
                mav.setViewName("redirect:/board/list");
                mav.addObject("msg", "notfound");
                return mav;
            }
            int result = boardService.deleteBoardData(boardId);
            if (result > 0) {
                deleteBlobIfExists(target.getBoardImg1());
                deleteBlobIfExists(target.getBoardImg2());
                deleteBlobIfExists(target.getBoardImg3());
                deleteBlobIfExists(target.getBoardImg4());
                mav.addObject("msg", "deleted");
            } else {
                mav.addObject("msg", "db_delete_failed");
            }
        } catch (Exception e) {
            log.error("게시글 삭제 오류", e);
            mav.addObject("msg", "error");
        }
        mav.setViewName("redirect:/board/list");
        return mav;
    }

    /** 댓글 등록 */
    @RequestMapping(value = "/reply/write", method = RequestMethod.POST)
    public String addReply(@ModelAttribute("reply") ReplyVo reply,
                           HttpServletRequest request,
                           HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        MemberVo loginUser = (MemberVo) session.getAttribute("member");
        if (loginUser == null) {
            return "redirect:/board/view?boardId=" + reply.getBoardId() + "&msg=loginRequired";
        }
        reply.setReplyWriter(loginUser.getNick());
        reply.setReplyWriterId(loginUser.getId());
        boardService.addReply(reply);
        return "redirect:/board/view?boardId=" + reply.getBoardId();
    }

    /** 댓글 삭제 */
    @RequestMapping(value = "/deleteReply", method = RequestMethod.POST)
    public ModelAndView deleteReply(HttpServletRequest request,
                                    HttpServletResponse response,
                                    @RequestParam("replyId") int replyId,
                                    @RequestParam("boardId") int boardId) throws Exception {
        ModelAndView mav = new ModelAndView();
        HttpSession session = request.getSession();
        MemberVo loginUser = (MemberVo) session.getAttribute("member");
        if (loginUser == null) {
            mav.addObject("msg", "댓글을 삭제하려면 로그인이 필요합니다.");
            mav.setViewName("redirect:/board/view?boardId=" + boardId);
            return mav;
        }
        int result = boardService.deleteReply(replyId, loginUser.getNick());
        if (result <= 0) mav.addObject("msg", "댓글 삭제에 실패했거나 권한이 없습니다.");
        mav.setViewName("redirect:/board/view?boardId=" + boardId);
        return mav;
    }

    /** 댓글 수정 (AJAX) */
    @RequestMapping(value = "/updateReply", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> updateReply(HttpServletRequest request,
                                           HttpServletResponse response,
                                           @RequestParam("replyId") int replyId,
                                           @RequestParam("replyCont") String replyCont) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        HttpSession session = request.getSession();
        MemberVo loginUser = (MemberVo) session.getAttribute("member");
        if (loginUser == null) {
            resultMap.put("status", "fail");
            resultMap.put("message", "로그인이 필요합니다.");
            return resultMap;
        }
        int result = boardService.updateReply(replyId, replyCont, loginUser.getNick());
        resultMap.put("status", result > 0 ? "success" : "fail");
        resultMap.put("message", result > 0 ? "댓글이 수정되었습니다." : "댓글 수정에 실패했거나 권한이 없습니다.");
        return resultMap;
    }

    /** 좋아요 추가 */
    @Override
    @RequestMapping(value = "/like", method = RequestMethod.POST)
    @ResponseBody
    public String boardLike(HttpServletRequest request,
                            HttpServletResponse response,
                            int boardId) throws Exception {
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");
            if (loginUser == null) return "login";

            BoardLikeVo likeVo = new BoardLikeVo();
            likeVo.setBoardLikeUser(loginUser.getId());
            likeVo.setBoardLikePost(boardId);

            boolean ok = boardService.addBoardLike(likeVo);
            if (!ok) return "fail";

            int total = boardService.getBoardLikeCount(boardId);
            boardService.updateBoardLikeCount(boardId, total);
            return String.valueOf(total);
        } catch (Exception e) {
            log.error("좋아요 처리 오류", e);
            return "error";
        }
    }

    /** 좋아요 취소 */
    @Override
    @RequestMapping(value = "/like/cancel", method = RequestMethod.POST)
    @ResponseBody
    public String boardLikeCancel(HttpServletRequest request,
                                  HttpServletResponse response,
                                  int boardId) throws Exception {
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");
            if (loginUser == null) return "login";

            BoardLikeVo likeVo = new BoardLikeVo();
            likeVo.setBoardLikeUser(loginUser.getId());
            likeVo.setBoardLikePost(boardId);

            boolean ok = boardService.cancelBoardLike(likeVo);
            if (!ok) return "fail";

            int total = boardService.getBoardLikeCount(boardId);
            boardService.updateBoardLikeCount(boardId, total);
            return String.valueOf(total);
        } catch (Exception e) {
            log.error("좋아요 취소 처리 오류", e);
            return "error";
        }
    }

    /** 좋아요 상태 조회 */
    @Override
    @RequestMapping(value = "/like/status", method = RequestMethod.POST)
    @ResponseBody
    public String boardLikeStatus(HttpServletRequest request,
                                  HttpServletResponse response,
                                  int boardId) throws Exception {
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");
            if (loginUser == null) return "login";

            BoardLikeVo likeVo = new BoardLikeVo();
            likeVo.setBoardLikeUser(loginUser.getId());
            likeVo.setBoardLikePost(boardId);
            return String.valueOf(boardService.checkBoardLikeStatus(likeVo));
        } catch (Exception e) {
            log.error("좋아요 상태 조회 오류", e);
            return "error";
        }
    }

    /** 좋아요 수 */
    @Override
    @RequestMapping(value = "/like/count", method = RequestMethod.POST)
    @ResponseBody
    public String boardLikeCount(HttpServletRequest request,
                                 HttpServletResponse response,
                                 int boardId) throws Exception {
        try {
            return String.valueOf(boardService.getBoardLikeCount(boardId));
        } catch (Exception e) {
            log.error("좋아요 수 조회 오류", e);
            return "error";
        }
    }

    /** 검색 */
    @Override
    @RequestMapping(value = "/search", method = RequestMethod.GET)
    public ModelAndView searchBoard(@RequestParam("keyword") String keyword,
                                    HttpServletRequest request,
                                    HttpServletResponse response) throws Exception {
        ModelAndView mav = new ModelAndView("/board/search");
        try {
            List<BoardVo> resultList = boardService.searchBoards(keyword);

            Map<String, MemberVo> memberCache = new HashMap<>();
            for (BoardVo board : resultList) {
                String writerId = board.getBoardWriterId();
                if (writerId != null && !writerId.isEmpty()) {
                    MemberVo info = memberCache.get(writerId);
                    if (info == null) {
                        info = memberService.selectMemberById(writerId);
                        if (info != null) memberCache.put(writerId, info);
                    }
                    if (info != null) board.setBoardWriterImg(info.getProfileImg());
                }
            }

            mav.addObject("top5List", boardService.getTop5BoardsByViews());
            mav.addObject("boardList", resultList);
            mav.addObject("keyword", keyword);
        } catch (Exception e) {
            log.error("검색 오류", e);
            mav.setViewName("/board/errorPage");
            mav.addObject("msg", "검색 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /** 카테고리 리스트 (AJAX) */
    @Override
    @RequestMapping(value = "/listByCategory", method = RequestMethod.GET)
    public String listByCategory(@RequestParam(value = "category", required = false) String category,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {
        List<BoardVo> boardList = (category == null || category.isEmpty())
                ? boardService.selectBoardList()
                : boardService.getBoardsByCategory(category);
        request.setAttribute("boardList", boardList);
        return "board/items";
    }

    /** 관리자 - 목록 */
    @Override
    @RequestMapping("/admin")
    public ModelAndView boardManage(HttpServletRequest request,
                                    HttpServletResponse response) throws Exception {
        ModelAndView mav = new ModelAndView("/admin/board");
        String searchType = request.getParameter("searchType");
        String keyword = request.getParameter("keyword");

        List<BoardVo> boardList = (searchType != null && keyword != null && !keyword.trim().isEmpty())
                ? boardService.searchBoardsForAdmin(searchType, keyword)
                : boardService.getAllBoardsForAdmin();

        mav.addObject("boardList", boardList);
        mav.addObject("searchType", searchType);
        mav.addObject("keyword", keyword);
        return mav;
    }

    
    /** 관리자 - 선택 삭제/저장 (현재 삭제만 사용) */
    @Override
    @RequestMapping(value = "/admin/saveOrDelete", method = RequestMethod.POST)
    public String deleteInAdmin(
            @RequestParam("action") String action,
            @RequestParam(value = "selectedIds", required = false) List<Integer> selectedIds,
            @ModelAttribute("boards") List<BoardVo> boards,
            HttpServletRequest request) {

        if ("delete".equals(action) && selectedIds != null && !selectedIds.isEmpty()) {
            for (Integer boardId : selectedIds) {
                try {
                    // 1) 삭제 전 이미지 정리 필요하면 원본 조회
                    BoardVo target = boardService.getBoardByIdWithoutIncrement(boardId);

                    // 2) DB 삭제 (프로젝트에 이미 있는 메서드 사용)
                    boardService.deleteBoardFromAdmin(boardId);

                    // 3) Blob 이미지가 절대 URL/오브젝트 경로로 저장되어 있다면 정리
                    if (target != null) {
                        deleteBlobIfExists(target.getBoardImg1());
                        deleteBlobIfExists(target.getBoardImg2());
                        deleteBlobIfExists(target.getBoardImg3());
                        deleteBlobIfExists(target.getBoardImg4());
                    }
                } catch (Exception e) {
                    log.error("관리자 삭제 실패 boardId={}", boardId, e);
                }
            }
        }
        return "redirect:/board/admin";
    }


    /** 관리자 - 수정 폼 */
    @Override
    @RequestMapping(value = "/admin/editAdmin/{boardId}", method = RequestMethod.GET)
    public ModelAndView editFormInAdmin(HttpServletRequest request,
                                        HttpServletResponse response,
                                        @PathVariable("boardId") int boardId) throws Exception {
        ModelAndView mav = new ModelAndView("/board/admEdit");
        try {
            BoardVo board = boardService.getBoardById(boardId);
            if (board == null) {
                mav.setViewName("redirect:/board/admin");
                return mav;
            }
            mav.addObject("board", board);
        } catch (Exception e) {
            log.error("관리자 수정 폼 로딩 오류 boardId: {}", boardId, e);
            mav.addObject("errorMessage", "게시글 정보를 불러오는 중 오류가 발생했습니다.");
        }
        return mav;
    }

    /** 관리자 - 수정 처리 */
    @Override
    @RequestMapping(value = "/admin/updateAdmin", method = RequestMethod.POST)
    public String updateInAdminBoard(HttpServletRequest request,
                                     HttpServletResponse response) throws Exception {
        try {
            int boardId = Integer.parseInt(request.getParameter("boardId"));
            String boardWriter = request.getParameter("boardWriter");
            String boardCont = request.getParameter("boardCont");
            String boardCate = request.getParameter("boardCate");

            BoardVo board = new BoardVo();
            board.setBoardId(boardId);
            board.setBoardWriter(boardWriter);
            board.setBoardCont(boardCont);
            board.setBoardCate(boardCate);

            boardService.updateBoardFromAdmin(board);
        } catch (Exception e) {
            log.error("관리자 게시글 수정 오류", e);
        }
        return "redirect:/board/admin";
    }

    /** 인기글 화면 (TOP5 + TOP100) */
    @Override
    @RequestMapping(value = "/hots", method = RequestMethod.GET)
    public ModelAndView top100List(HttpServletRequest request,
                                   HttpServletResponse response) throws Exception {
        ModelAndView mav = new ModelAndView("/board/hots");
        try {
            HttpSession session = request.getSession();
            MemberVo loginUser = (MemberVo) session.getAttribute("member");

            List<BoardVo> boardList = boardService.selectBoardList();
            Map<String, MemberVo> memberCache = new HashMap<>();

            for (BoardVo board : boardList) {
                int boardId = board.getBoardId();
                board.setBoardRe(boardService.getReplyCountByBoardId(boardId));
                board.setBoardLike(boardService.getBoardLikeCount(boardId));

                if (loginUser != null) {
                    BoardLikeVo likeVo = new BoardLikeVo();
                    likeVo.setBoardLikeUser(loginUser.getId());
                    likeVo.setBoardLikePost(boardId);
                    boolean isLiked = boardService.checkBoardLikeStatus(likeVo);
                    mav.getModel().computeIfAbsent("likedPosts", k -> new HashMap<Integer, Boolean>());
                    @SuppressWarnings("unchecked")
                    Map<Integer, Boolean> likedPosts = (Map<Integer, Boolean>) mav.getModel().get("likedPosts");
                    likedPosts.put(boardId, isLiked);
                }

                String writerId = board.getBoardWriterId();
                if (writerId != null && !writerId.isEmpty()) {
                    MemberVo info = memberCache.get(writerId);
                    if (info == null) {
                        info = memberService.selectMemberById(writerId);
                        if (info != null) memberCache.put(writerId, info);
                    }
                    if (info != null) board.setBoardWriterImg(info.getProfileImg());
                }

                if (board.getBoardCont() != null) {
                    board.setBoardCont(board.getBoardCont().replaceAll("(\r\n|\r|\n)", "<br />"));
                }
            }

            mav.addObject("top5List", boardService.getTop5BoardsByViews());
            mav.addObject("top100List", boardService.getTop100BoardsByViews());
            mav.addObject("boardList", boardList);
        } catch (Exception e) {
            log.error("인기글 페이지 로딩 오류", e);
            mav.addObject("msg", "게시글 목록을 불러오는 중 오류가 발생했습니다.");
        }
        return mav;
    }
}
