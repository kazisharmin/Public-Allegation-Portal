// frontend/src/pages/Help_page.jsx
import React from "react";
import { Link } from "react-router-dom";
import { getToken } from "../utils/auth";

const FAQS = [
  {
    q: "What is the Public Allegation Portal?",
    a: "A place where people can raise complaints about organizations (for example a municipality, a university or a utility) and follow what happens to them. Organizations see the complaints, update their status and reply through notifications.",
  },
  {
    q: "Can I complain without revealing who I am?",
    a: "Yes. Use \"File an anonymous complaint\" on the home page, or tick the anonymous option when you file while logged in. Anonymous complaints never show your name to the organization or to other users.",
  },
  {
    q: "How do I join an organization?",
    a: "Register as a user and pick the organization you belong to. Private organizations only show their complaints to their own members, so you need to join them to see and vote on complaints.",
  },
  {
    q: "What do the complaint statuses mean?",
    a: "Open: just submitted. Pending: waiting for the organization. In Progress: someone is working on it. Resolved: fixed. Rejected: the organization decided not to act. Withdrawn: you took it back.",
  },
  {
    q: "Can I edit or withdraw my complaint?",
    a: "You can edit the title and description within 24 hours, while it is still Open or Pending. You can withdraw it at any time and restore it within 30 days; after that, withdrawn complaints are deleted.",
  },
  {
    q: "What does voting do?",
    a: "Voting shows the organization that many people care about the same problem, so it can prioritise. You get one vote per complaint, and you can remove it by clicking again.",
  },
  {
    q: "I'm an organization. How do I get started?",
    a: "Register as an organization, then add your departments. Complaints can be sent to a department or to the whole organization, and you can change each complaint's status from your organization page.",
  },
];

export default function Help_page() {
  const loggedIn = Boolean(getToken());
  const backTo = loggedIn ? "/user/dashboard" : "/";
  const backLabel = loggedIn ? "← Back to Dashboard" : "← Back to Home";

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-3xl mx-auto p-6">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-semibold text-green-700">Help &amp; Support</h1>
          <Link to={backTo} className="text-sm text-green-700 underline">
            {backLabel}
          </Link>
        </div>

        <div className="space-y-3">
          {FAQS.map((item) => (
            <details
              key={item.q}
              className="group rounded-2xl bg-white p-5 shadow-sm ring-1 ring-gray-100"
            >
              <summary className="cursor-pointer list-none font-medium text-slate-800 flex justify-between items-center">
                {item.q}
                <span className="text-green-700 transition-transform group-open:rotate-45 text-xl leading-none">+</span>
              </summary>
              <p className="mt-3 text-sm text-gray-600 leading-relaxed">{item.a}</p>
            </details>
          ))}
        </div>

        <div className="mt-8 rounded-2xl bg-green-50 p-5 ring-1 ring-green-100">
          <h2 className="font-medium text-green-800">Still need help?</h2>
          <p className="mt-1 text-sm text-green-900/80">
            Contact the organization directly from its page, or email the portal team at{" "}
            <a href="mailto:ksnftaz@gmail.com" className="underline">ksnftaz@gmail.com</a>.
          </p>
        </div>
      </div>
    </div>
  );
}
