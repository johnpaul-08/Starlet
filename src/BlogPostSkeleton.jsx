import React from 'react';
import './BlogPostSkeleton.css';

/**
 * A single skeleton card that mimics the real blog-post-card layout:
 *   - header  (avatar circle + two text lines)
 *   - media   (square-ish image / video placeholder)
 *   - footer  (star icon stub + caption line)
 */
const SkeletonCard = () => (
  <div className="bps-card" aria-hidden="true">
    {/* ── Header ── */}
    <div className="bps-header">
      <div className="bps-avatar bps-shim" />
      <div className="bps-meta">
        <div className="bps-line bps-line--name bps-shim" />
        <div className="bps-line bps-line--time bps-shim" />
      </div>
      {/* dots-menu ghost */}
      <div className="bps-dots bps-shim" />
    </div>

    {/* ── Media ── */}
    <div className="bps-media bps-shim" />

    {/* ── Footer ── */}
    <div className="bps-footer">
      <div className="bps-star bps-shim" />
      <div className="bps-line bps-line--caption bps-shim" />
    </div>
  </div>
);

/**
 * BlogPostSkeleton
 * Props:
 *   count  {number}  – how many skeleton cards to render (default 3)
 */
const BlogPostSkeleton = ({ count = 3 }) => (
  <div className="bps-list">
    {Array.from({ length: count }, (_, i) => (
      <SkeletonCard key={i} />
    ))}
  </div>
);

export default BlogPostSkeleton;
